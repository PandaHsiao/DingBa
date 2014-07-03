class RegistrationsController < Devise::RegistrationsController
  #layout 'restaurant_manage'
  layout 'registration'

  # ====== Code Check: 2013/12/25 ====== [ panda: ok ]
  # GET ==== Function: show registration restaurant view
  # =========================================================================
  def restaurant_new
    @restaurant = Restaurant.new
  end

  # ====== Code Check: 2013/12/25 ====== [ panda: TODO: phase 2]
  # POST === Function: create restaurant role user
  # =========================================================================
  def restaurant_create
    begin
      user_create('devise/registrations/restaurant_new', '0')
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/registrations_controller.rb ,Action:restaurant_create"
      flash.now[:alert] = '發生錯誤! 註冊失敗!'
      render 'devise/registrations/restaurant_new'
    end
  end

  # ====== Code Check: 2013/12/25 ====== [ panda: ok ]
  # GET ==== Function: show registration booker view
  # =========================================================================
  def booker_new
  end

  # ====== Code Check: 2013/12/25 ====== [ panda: ok ]
  # POST === Function: create booker role user
  # =========================================================================
  def booker_create
    begin
      user_create('devise/registrations/booker_new', '1')
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/registrations_controller.rb ,Action:booker_create"
      flash.now[:alert] = '發生錯誤! 註冊失敗!'
      render 'devise/registrations/restaurant_new'
    end
  end

  # ====== Code Check: 2013/12/25 ====== [ panda: ok ]
  # Method === Function: validation params and save user
  # =========================================================================
  def user_create(from_url, role)
    name = params[:tag_name].strip
    email = params[:tag_email].strip
    phone = params[:tag_phone].strip
    sex = params[:tag_sex]
    birthday_param = params[:tag_birthday]

    if role == '1' && birthday_param.present?
      birthday = Time.parse(birthday_param['(1i)'].to_s + "-" + birthday_param['(2i)'].to_s + "-" + birthday_param['(3i)'].to_s)
    end
    allow_promot = params[:tag_allow_promot]
    password = params[:tag_password].strip
    i_agree = params[:tag_i_agree]    # nil mean not agree clause

    #============================================== invite code
    if APP_CONFIG['enable_invite_code'] == 'true' && from_url.include?('restaurant')
      invite_code = params[:tag_invite_code].strip
      if invite_code.blank?
        flash.now[:alert] = '您好，現在Dingba 處於私密測試階段，為了維持訂吧網路服務的品質，我們需要取得邀請碼後才能進行免費的餐廳服務申請。  若您還對我們服務有興趣，可以先留下:餐廳名稱:   聯絡人:  餐廳官方網站或FB:   並 Email 至 cs@codream.tw，我們會盡快協助您加入訂吧的免費服務。'
        render from_url
        return
      end

      result = InviteCode.where(:code => invite_code, :user_id => nil)
      if result.blank?
        flash.now[:alert] = '沒有此筆邀請碼喔~ 很抱歉!'
        render from_url
        return
      end

    end
    #==============================================

    if (name.blank? || email.blank? || phone.blank? || password.blank? || i_agree.blank?)
      flash.now[:alert] = '有欄位未填喔!'
      render from_url
      return
    end

    if (email =~ /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/).blank?
      flash.now[:alert] = 'E-mail 格式錯誤!'
      render from_url
      return
    end

    if i_agree != '1'
      flash.now[:alert] = '資料異常! 註冊失敗!'
      render from_url
      return
    end

    user = User.where(:email => email)
    if !user.blank?
      flash.now[:alert] = '此帳號 ( E-Mail ) 已被註冊'
      render from_url
      return
    end

    person =  { 'name' => name,
                'email' => email,
                'phone' => phone,
                'role' => role,              # 0 = restaurant, 1 = booker
                'password' => password,
                'password_confirmation' => password,
                'sex' => sex,
                'birthday' => birthday,
                'allow_promot' => allow_promot}
    devise_save(person, invite_code)
  end

  # ====== Code Check: 2013/12/25 ====== [ panda: TODO: detail review ]
  # Method === Function: save user
  # =========================================================================
  def devise_save(person, invite_code)

    User.transaction do
      build_resource(person)
      if resource.save
        if person['role'] == '0'
          result = restaurant_init(person['phone'], resource)
          if result[0] == false
            flash.now[:alert] = result[1]
            render 'devise/registrations/restaurant_new'
            raise ActiveRecord::Rollback
            #make_error =  1/0  # template solve the hack attack or man make error situation
          end
        end

        if !invite_code.blank?
          code_record = InviteCode.where(:code => invite_code).first
          code_record.user_id = resource.id
          code_record.save
        end

        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_navigational_format?
          sign_up(resource_name, resource)
          respond_with resource, :location => after_sign_up_path_for(resource)
        else
          set_flash_message :notice, :'signed_up_but_#{resource.inactive_message}' if is_navigational_format?
          expire_session_data_after_sign_in!
          @user_email = resource.email
          #redirect_to '/home/wait_confirm_email'
          render '/home/wait_confirm_email', layout: 'registration'
          return
          #respond_with resource, :location => after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        #respond_with resource
        error = resource.errors.first[1]
        flash.now[:alert] = error
        render 'devise/registrations/restaurant_new'
      end

    end
  end

  # ====== Code Check: 2013/12/25 ====== [ panda: ok ]
  # Method === Function: init restaurant data
  # =========================================================================
  def restaurant_init(phone, user)
    # max_seq = Restaurant.maximum(:res_url)
    res_url_tag = get_res_url_tag
    res = Restaurant.new
    res.phone = phone
    res.res_url = res_url_tag         # APP_CONFIG['domain']
    res.available_type = '1'
    res.available_date = '22:00'
    res.available_hour = 1
    res.sent_type = '0'
    res.sent_date = '22:00'
    res.supply_person = user.name
    res.supply_email = user.email

    if res.save
      res_user = RestaurantUser.new
      res_user.restaurant_id = res.id
      res_user.permission = '0'           # 0 mean all manager
      res_user.user_id = user.id

      if res_user.save
        return [true, 'success']
      else
        error_message = res_user.errors.first[1]
        return [false, error_message]
      end
    else
      error_message = res.errors.first[1]
      return [false, error_message]
    end
  end

  # ====== Code Check: 2013/12/25 ====== [ panda: ok ]
  # Method === Function: get restaurant url tag
  # =========================================================================
  def get_res_url_tag
    rand_string = SecureRandom.hex(3)
    check = Restaurant.where(:res_url => rand_string)

    if check.blank?
      return rand_string
    else
      get_res_url_tag
    end
  end

  def account_edit
    @booker = current_user
    @from = 'res'
    render 'devise/registrations/edit', :layout => false, :locals => { :resource => @booker, :resource_name => 'user'}
  end

  # ====== Code Check: 2013/12/25 ====== [ panda: TODO: detail review ]
  # POST === Function: update user data
  # =========================================================================
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    #prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    taget_user = registration_params

    if resource.provider.blank?
      taget_user[:password] = taget_user[:password]
      taget_user[:password_confirmation] = taget_user[:password_confirmation]
      taget_user[:current_password] = taget_user[:current_password]
    end
    taget_user[:name] = taget_user[:name].strip
    taget_user[:phone] = taget_user[:phone].strip
    taget_user[:birthday] = "#{params['birthday(1i)']}#{params['birthday(2i)']}#{params['birthday(3i)']}"

    if taget_user[:password] != taget_user[:password_confirmation]
      result = '新密碼與確認新密碼不符'
    elsif !taget_user[:password].blank? && !taget_user[:password_confirmation].blank? && taget_user[:password].length < 6
      result = '密碼長度必須大於6個字元, 前後不能空白'
    elsif taget_user[:name].blank?
      result = '姓名為必填欄位喔!'
    elsif taget_user[:phone].blank?
      result = '電話為必填欄位喔!'
    else

      if resource.provider.blank?
        if taget_user[:current_password].blank?
          result = '驗證碼為必填欄位喔!'
        else
          if update_resource(resource, taget_user)
            sign_in resource_name, resource, :bypass => true
            result = '修改成功'
          else
            clean_up_passwords resource
            result = '修改失敗! 請確認輸入資料是否正確!,或資料長度超過限制'
          end
        end
      else
        #if update_resource(resource, taget_user)
        if resource.update_without_password(taget_user)
          #if is_navigational_format?
          #  flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          #      :update_needs_confirmation : :updated
          #  #set_flash_message :notice, flash_key
          #end
          sign_in resource_name, resource, :bypass => true
          #respond_with resource, :location => '/booker_manage/index' #after_update_path_for(resource)
          result = '修改成功'
        else
          clean_up_passwords resource
          result = '修改失敗! 請確認輸入資料是否正確!,或資料長度超過限制'
        end
      end
    end

    from = params[:from]
    if from.blank?
      #render json:{:edit_account => true, :message => result, :attachmentPartial => render_to_string('devise/registrations/edit', :layout => false, :locals => { :resource => resource,:resource_name => 'user'}) }
      redirect_to '/booker_manage/index#tabs-2', :alert => result
    else
      render json:{:success => true, :data => result, :registration => true }
    end
  end

  def registration_params
    params.require(:user).permit(:name, :phone, :email, :password, :password_confirmation, :current_password, :birthday, :sex, :allow_promot)
  end
end