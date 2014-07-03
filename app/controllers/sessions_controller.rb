class SessionsController < Devise::SessionsController
  #layout 'restaurant_manage'
  layout 'registration'

  def restaurant_new
    begin
      if current_user.present? && current_user.role == '1'
        redirect_to turn_to_restaurant_path
      else
        new_user('0', nil)
      end
    rescue => e
    end
  end

  def booker_new
    #@res_url = params[:format]
    #@res_url = @res_url[0..5]
    booker_url = params[:res_url]
    new_user('1', booker_url)
  end

  def guest_login_check
    @id = params[:id]
    @is_check_login = params[:is_check_login]
    render :layout => false
  end

  def new_user(role, booker_url)
    begin
      if !current_user.blank?    # when not confirm email will error
        if !booker_url.blank?
          @id = booker_url
          @is_check_login = true
          redirect_to booking_restaurant_path(:id => @id, :is_check_login => @is_check_login)
        elsif role == '0' && current_user.role == '0'
          restaurant_users = RestaurantUser.where(:user_id => current_user.id)
          restaurant = Restaurant.find(restaurant_users.first.restaurant_id)

          if RestaurantManage.check_restaurant_info(restaurant)
            if RestaurantManage.check_supply_condition(restaurant.id)
              redirect_to '/restaurant#/calendar/restaurant_month'
            else
              redirect_to '/restaurant#/restaurant_manage/supply_condition'
            end
          else
            redirect_to confirmation_getting_started_path
          end
        elsif role == '1'
          redirect_to booker_manage_index_path
        end
      else
        if !booker_url.blank?
          session[:res_url] = booker_url
          @id = booker_url
          @is_to_booking = true
          @is_check_login = true
          #redirect_to booking_restaurant_path(:id => @id, :is_check_login => @is_check_login)
          self.resource = resource_class.new
          clean_up_passwords(resource)
          respond_with(resource, serialize_options(resource), :id => @id, :is_check_login => @is_check_login, :is_to_booking => @is_to_booking)
        else
          self.resource = resource_class.new
          clean_up_passwords(resource)
          respond_with(resource, serialize_options(resource))
        end
      end
    rescue => e
      #Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/sessions_controller.rb  ,Method:new(sign_in_params)"
      #if role == '0'
      #  redirect_to res_session_new_path
      #else
      #  redirect_to booker_session_new_path
      #end
    end
  end

  # POST /resource/sign_in
  def create
    user = params[:user]

    begin
      target_user = User.where(:email => user[:email])

      if target_user.blank?
        flash.now[:alert] = '沒有此E-Mail 資料!'
        if user[:role] == '0'
          self.resource = resource_class.new
          render 'devise/sessions/restaurant_new'
        elsif user[:role] == '1'
          self.resource = resource_class.new
          render 'devise/sessions/booker_new'
        end
        return
      else
        if !target_user.first.provider.blank?
          if user[:role] == '0'
            flash.now[:alert] = "此帳號是用 #{target_user.first.provider} 登入!"
            self.resource = resource_class.new
            render 'devise/sessions/restaurant_new'
          elsif user[:role] == '1'
            flash.now[:alert] = "此帳號是用 #{target_user.first.provider} 登入!"
            self.resource = resource_class.new
            render 'devise/sessions/booker_new'
          end
          return
        end
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/sessions_controller.rb  ,Action:create"
      redirect_to home_path
      return
    end

    begin
      if target_user.first.confirmation_token.length != 20
        if user[:role] == '0'
          flash.now[:alert] = '信箱尚未驗證!!'
          self.resource = resource_class.new
          render 'devise/sessions/restaurant_new'
        elsif user[:role] == '1'
          flash.now[:alert] = '信箱尚未驗證!!'
          self.resource = resource_class.new
          render 'devise/sessions/booker_new'
        end
        return
      end

      self.resource = warden.authenticate(auth_options)  #warden.authenticate!(auth_options)

      if self.resource.blank?
        flash.now[:alert] = '密碼錯誤!'
        if user[:role] == '0'
          new_user('0', nil)
          render 'devise/sessions/restaurant_new'
        elsif user[:role] == '1'
          new_user('1', nil)
          render 'devise/sessions/booker_new'
        end
        return
      end

      sign_in(resource_name, resource)
      yield resource if block_given?
      redirect_to after_sign_in_path_for_custom(resource, params[:id])
      #respond_with resource, :location => after_sign_in_path_for(resource)

    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/sessions_controller.rb  ,Action:create"
      redirect_to home_path
      return
    end
  end

  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))

    respond_to do |format|
      format.json { render :json => {:sign_out => true } }
      format.html { redirect_to :back}
    end
  end

end