class HomeController < ApplicationController
  #layout 'home'
  layout :resolve_layout
  before_action :get_user, :only => [:wait_confirm_email, :index_old, :booking_restaurant, :get_condition, :save_booking, :notice_friend, :cancel_booking, :save_cancel_booking]

  # =========================================================================
  # panda: 我比較偏向不使用path,因為命名這件事讓trace code變得麻煩一點(must see routes),雖然path可以讓rename 好管理,但基本上!! rename畢竟是很少發生的情況
  # flash.now[:alert] = result
  # render no stop the process, must add return
  # booking status 0 = 已訂位
  # booking status 1 = 待評論 feedback != nil 已評論
  # booking status 2 = 同伴無法配合
  # booking status 3 = 餐廳當天座位不夠
  # booking status 4 = 選擇了其他餐廳
  # booking status 5 = 餐廳臨時公休
  # booking status 6 = 聚餐延期
  # booking status 7 = 其他
  # role = 0 餐廳
  # role = 1 使用者
  # is_special = 't', 'f'
  # is_vacation = 't', 'f'
  # =========================================================================

  def about_codream
  end

  def clause
  end

  def q_and_a
  end

  def turn_to_restaurant
  end

  def turn_restaurant_with_invite
    invite_code = params[:invite_code].strip

    if invite_code.blank?
      render json:{:error => true , :message => '邀請碼不能空白喔！'}
      return
    end

    code_records = InviteCode.where(:code => invite_code, :user_id => nil)
    if code_records.blank?
      render json:{:error => true , :message => '沒有此筆邀請碼！'}
      return
    end

    target_user = nil
    if current_user.present? && current_user.role == '1'
      target_user = User.find(current_user.id)
    end

    if target_user.blank?
      render json:{:error => true , :message => '疑～你好像登出了～ 麻煩你先登入再進行建立動作喔~！'}
      return
    end

    User.transaction do
      target_user.role = '0'
      target_user.allow_promot = 't'
      target_user.save

      code_record = code_records.first
      code_record.user_id = target_user.id
      code_record.save

      res_url_tag = get_res_url_tag
      res = Restaurant.new
      res.res_url = res_url_tag         # APP_CONFIG['domain']
      res.available_type = '1'
      res.available_date = '22:00'
      res.available_hour = 1
      res.sent_type = '0'
      res.sent_date = '22:00'
      res.supply_person = target_user.name
      res.supply_email = target_user.email
      res.save

      res_user = RestaurantUser.new
      res_user.restaurant_id = res.id
      res_user.permission = '0'           # 0 mean all manager
      res_user.user_id = target_user.id
      res_user.save
      render json:{:success => true , :data => '建立餐廳成功~'}
    end
  end

  def get_res_url_tag
    rand_string = SecureRandom.hex(3)
    check = Restaurant.where(:res_url => rand_string)

    if check.blank?
      return rand_string
    else
      get_res_url_tag
    end
  end

  def index
    # DingBa home view
    # TODO GET Home restaurant
    # updated_at , set home tag save updated_at time,
    @restaurants = Restaurant.where(:tag => 'home')
    if  $my_friends_list.nil?
      reload_friends
    end

  end

  def get_invite_code
    render 'home/get_invite_code', :layout => false
  end

  def save_get_code_person
    email = params[:email].strip
    # Very Important user remote = true, 告訴jquery_ujs.js這個部分要非同步處理
    # 重導向或是渲染模板都沒有效果，這是很正常的，因為預設接受的回應是JavaScript
    # 但使用非同步傳輸，建議此功能如果壞掉，是不影響功能的為前提，因為我會先判定成功，再由後台錯誤訊息決定
    begin
      if !(email =~ /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/).blank?
        send_mail_result = MyMailer.invite_code_notice(email, params[:restaurant_name], params[:user_name], params[:phone],APP_CONFIG['dingba_email']).deliver
      else
        render json:{:error => true , :message => '申請人 E-Mail 格式錯誤'}
      end

      if !send_mail_result.blank?
        render json:{:success => true }
      else
        render json:{:error => true , :message => '線上申請異常，請撥電 DingBa 直接索取，謝謝'}
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/home_controller.rb  ,Method:save_get_code_person"
      render json:{:error => true , :message => '線上申請異常，請撥電 DingBa 直接索取，謝謝'}
    end
  end

  def index_old
  end

  def wait_confirm_email
    if !@booker.id.blank?
      if @booker.role == '0'
        redirect_to confirmation_getting_started_path
      elsif @booker.role == '1'
        redirect_to booker_manage_index_path
      end
    end

    @user_email = @user_email
  end

  # GET the booking url ,when restaurant 2000 ,build home page, and move booking page to this place
  def booking_restaurant
    restaurant_url = params[:id]
    booking_day = params[:booking_day]


    @booking_day = (Date.parse(Time.now.to_s) + 1.days).to_s
    if !booking_day.blank?
      @booking_day = booking_day
    end

    restaurant_url = restaurant_url[0..5]
    restaurant = Restaurant.new
    restaurant = Home.get_restaurant(restaurant_url)
    @res_url = restaurant_url

    if restaurant.blank?
      redirect_to home_path
      return
    end

    @pay_type = "#{restaurant.pay_type}"
    @address = "#{restaurant.city} #{restaurant.area} #{restaurant.address}"
    @restaurant = restaurant

    @booking_condition = BookingCondition.new
    @booking_condition.option_of_time = []
    if !@restaurant.blank?
      @booking_condition = BookingCondition.new
      @booking_condition.option_of_time = []
      @booking_condition = Home.get_condition(@restaurant, @booking_day)
    else
      redirect_to home_path
    end

    @page_title ="DingBa訂吧-" + @restaurant.name

    if params[:is_check_login] != "true"
      @is_to_booking = true
      redirect_to booker_session_new_path(:res_url => @res_url)
    else
      @is_check_login = true
    end
  end

  def get_condition
    restaurant_url = params[:id]
    @booking_day = params[:booking_day]
    restaurant_url = restaurant_url[0..5]
    @restaurant = Restaurant.new
    @restaurant = Home.get_restaurant(restaurant_url)
    @booking_condition = BookingCondition.new
    if !@restaurant.blank?
      @booking_condition = BookingCondition.new
      @booking_condition = Home.get_condition(@restaurant, @booking_day)

      result = {:success => true, :attachmentPartial => render_to_string('home/_booking_zone', :layout => false, :locals => { :booking_condition => @booking_condition, :booking_day => @booking_day, :restaurant => @restaurant, :booker => @booker })}
      render json: result
    else
      render json: {:error => true, :message => '沒有此家餐廳!'}
    end
  end

  def save_booking
    result = Home.save_booking(@booker, params[:booking])

    #result = {:success => true, :attachmentPartial => render_to_string('home/_booking_zone', :layout => false, :locals => { :booking_condition => @booking_condition, :booking_day => @booking_day, :restaurant => @restaurant, :booker => @booker })}
    render json: result
  end

  def notice_friend
    begin
      booking_id = params[:booking_id].to_i
      notice_emails = params[:notice_emails].strip

      if booking_id.blank? || notice_emails.blank?
        render json: {:error => true, :message => '阿! 發生錯誤了! 通知失敗!'}
        return
      end

      email = notice_emails.split(',')
      if email.count == 1
        email = email[0].split(';')
      end

      booking = Booking.find(booking_id)

      effect_email = []
      email.each do |e|
        if !e.blank? && !(e =~ /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/).blank?
          effect_email.push(e)
        end
      end

      booking.phone = nil
      booking.res_url = APP_CONFIG['domain'] + "#{booking.res_url}"
      #result = MyMailer.notify_friend(effect_email ,booking).deliver
      result = MyMailer.delay_for(1.second).notify_friend(effect_email ,booking.id, APP_CONFIG['domain'])   # sidekiq

      #==========================================================================  use sidekiq can't not know the result immediate
      #if result.perform_deliveries
      #
      #  #booking = Booking.find(booking_id)
      #  booking.participants = effect_email.map{|k| "#{k}"}.join(',')
      #  booking.save
      #  render json: {:success => true, :data => '通知成功!' }
      #else
      #  render json: {:error => true, :message => '阿! 發生錯誤了! 通知失敗!'}
      #end
      #==========================================================================
      render json: {:success => true, :data => '通知成功!' }

    rescue => e
      render json: {:error => true, :message => '阿! 發生錯誤了! 通知失敗!'}
    end
  end

  def cancel_booking
    begin
      #@booking = Booking.find(1)
      @booking = Booking.find(params[:booking_id].to_i)
      @restaurant = Restaurant.find(@booking.restaurant_id)
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/home_controller.rb ,Action:cancel_booking"
      render json: {:error => true, :message => '阿! 發生錯誤了! 資料異常!'}
    end
  end

  def save_cancel_booking
    result = RestaurantManage.cancel_booking(params[:booking_id], params[:status], params[:cancel_note], true)
    render json: result
  end

  def cancel_booking_by_email
    begin
      booking_key = params[:booking_key]
      cancel_key = params[:cancel_key]

      if booking_key.blank? || cancel_key.blank?
        render json: '阿! 發生錯誤了! 資料異常!'
        return
      end
      @booking = Booking.find(booking_key.to_i)
      if @booking.cancel_key != cancel_key
        render json: '阿! 發生錯誤了! 資料異常!'
        return
      end

      @booking.phone = nil
      @booking.res_url = APP_CONFIG['domain'] + "#{@booking.res_url}"
      @restaurant = Restaurant.find(@booking.restaurant_id)
      @pay_type = "#{@restaurant.pay_type}"
      render 'cancel_booking'
    rescue => e
      #Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/home_controller.rb ,Action:cancel_booking_by_email"
      render json: '阿! 發生錯誤了! 資料異常!'
    end
  end

  def save_cancel_booking_by_email

    result = RestaurantManage.cancel_booking_email(params[:booking])

    error = result[:error]
    success = result[:success]

    if error
      result_message = result[:message]
    elsif success
      result_message = result[:data]
    end

    flash.now[:alert] = result_message

    @booking = Booking.find(params[:booking][:id].to_i)
    @booking.res_url = APP_CONFIG['domain'] + "#{@booking.res_url}"
    @booking.phone = nil
    @restaurant = Restaurant.find(@booking.restaurant_id)
    @pay_type = "#{@restaurant.pay_type}"
    render 'cancel_booking'
  end

  def get_user
    begin
      @booker = User.new
      if !current_user.blank?
        #if current_user.role == '0'   # restaurant
        #signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
        #redirect_to confirmation_getting_started_path
        #elsif current_user.role == '1'  # booker
        @booker = User.find(current_user.id)
        #end
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/home_controller.rb  ,Filter:get_user"
      flash.now[:alert] = 'oops! 出現錯誤了!'
      redirect_to home_path
    end
  end

  #==========================================================
  def create_invite_code
    result = InviteCode.where('id > ?', 1)
    if result.blank?
      code_array = []

      while code_array.count() < 5000 do
        code = 10000000 + SecureRandom.random_number(89999999).to_i
        obj = InviteCode.new
        obj.code = code

        if !code_array.include?(obj)
          x = obj.attributes
          code_array.push(x)
        end
      end

      InviteCode.create(code_array)
    end
  end
  #==========================================================

  private

  def resolve_layout
    case action_name
      when 'index_old', 'clause', 'about_codream', 'q_and_a', 'wait_confirm_email', 'cancel_booking_by_email', 'save_cancel_booking_by_email', 'turn_to_restaurant'
        'home_index_old'
      when 'index'
        'home_index'
      else
        'home'
    end
  end

  def reload_friends
    require 'google_drive'
    google_session =  GoogleDrive.login('streams.in.taipei@gmail.com', DingBa::Application::Google_Driver_Login_P)
    # First worksheet of https://docs.google.com/spreadsheet/ccc?key=pz7XtlQC-PYx-jrVMJErTcg
    $my_friends_list =  google_session.spreadsheet_by_key('0Au6aqiVMytnzdF9QejN3T19oRzZXME41blhfX2tzelE').worksheets[1]

  end


end
