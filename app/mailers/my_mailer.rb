class MyMailer < ActionMailer::Base
  #default from: "a17877yun@gmail.com"
  #include Resque::Mailer

  def invite_code_notice(email, restaurant_name, person, phone, recive_email)
    begin
      @restaurant_name = restaurant_name
      @person = person
      @phone = phone
      @email = email

      mail(to: recive_email,
           subject: '訂吧通知：' + restaurant_name + '索取邀請碼！') do |format|
        format.html { render 'my_mailer/invite_code_notice' }
      end

      return true
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/Mailers/booking_success.rb ,Method:invite_code_notice(email, restaurant_name, person, phone)"
      return false
    end
  end

  def notice_cancel_booking(email, restaurant_id, booking_id, domain)
  #def notice_cancel_booking(email, restaurant, booking)  *p1
    begin
      #@restaurant = restaurant    *p1
      #@booking = booking      *p1
      @booking = Booking.find(booking_id)
      @booking.res_url = domain + "#{@booking.res_url}"
      @restaurant = Restaurant.find(restaurant_id)

      mail(to: email,
           subject: '訂吧通知：顧客' + @booking.name + ' 取消 ' + @booking.booking_time.strftime("%Y-%m-%d %H:%M") + ' 訂位！ ，取消人數：' + @booking.num_of_people.to_s + ' 人') do |format|
        format.html { render 'my_mailer/notice_cancel_booking' }
      end

      return true
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/Mailers/booking_success.rb ,Method:notice_cancel_booking(email, restaurant, booking)"
      return false
    end
  end

  def booking_success(booking_id, domain, domain_clear)
  #def booking_success(email, booking)   *p1
    begin
      #@booking = booking *p1
      @booking = Booking.find(booking_id)
      @booking.phone = nil
      @booking.res_url = domain + "#{@booking.res_url}"
      @booking.cancel_key = domain_clear + "home/cancel_booking_by_email?cancel_key=" + "#{@booking.cancel_key}"  + "&booking_key=" + "#{@booking.id}"

      #@domain_clear = APP_CONFIG['domain_clear'] + "home/cancel_booking_by_email/"
      email = @booking.email
      mail(to: email,
           subject: '訂吧通知：您的訂位成功！') do |format|
        format.html { render 'my_mailer/booking_success' }
      end
      #handle_asynchronously :booking_success #, :run_at => Proc.new { 1.minutes.from_now }
      return true
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/Mailers/booking_success.rb ,Method:booking_success(email, booking_id)"
      return false
    end
  end

  def notify_friend(effect_email, booking_id, domain)
  #def notify_friend(effect_email, booking)
    begin
      #@booking = booking    *p1
      @booking = Booking.find(booking_id)
      @booking.phone = nil
      @booking.res_url = domain + "#{@booking.res_url}"

      mail(to: effect_email,
           subject: '訂吧通知：您的朋友邀請您一起用餐！') do |format|
        format.html { render 'my_mailer/booking_friend' }
      end

      return true
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/Mailers/my_mailer.rb ,Method:notify_friend(email, booking_id)"
      return false
    end
  end

  def cancel_booking(booking_id, domain)
  #def cancel_booking(email, booking)
    begin
      #@booking = booking    *p1
      @booking = Booking.find(booking_id)
      @booking.phone = nil
      @booking.res_url = domain + "#{@booking.res_url}"
      email = @booking.email
      mail(to: email,
           subject: '訂吧通知：您的訂位已取消！') do |format|
        format.html { render 'my_mailer/cancel_booking' }
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/Mailers/my_mailer.rb ,Method:cancel_booking(email, booking)"
      return false
    end
  end

  def modify_booking(booking_id, domain, domain_clear)
  #def modify_booking(email, booking)
    begin
      #@booking = booking    *p1
      @booking = Booking.find(booking_id)
      @booking.phone = nil
      @booking.res_url = domain + "#{@booking.res_url}"
      @booking.cancel_key = domain_clear + "home/cancel_booking_by_email?cancel_key=" + "#{@booking.cancel_key}"  + "&booking_key=" + "#{@booking.id}"
      email = @booking.email

      mail(to: email,
           subject: '訂吧通知：您的訂位已由餐廳方修改，請再次確認！') do |format|
        format.html { render 'my_mailer/modify_booking' }
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/Mailers/my_mailer.rb ,Method:modify_booking(email, booking)"
      return false
    end
  end

  def restaurant_daily_report(report_day ,restaurant_name, email, restaurant_books)
    begin
      @restaurant_name = restaurant_name
      @restaurant_books = restaurant_books
      @report_day = report_day

      mail(to: email,
           subject: '訂吧報表：餐廳日訂位報表！') do |format|
        format.html { render 'my_mailer/restaurant_daily_report' }
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/Mailers/my_mailer.rb ,Method:restaurant_daily_report(report_day ,restaurant_name, email, restaurant_books)"
      return false
    end
  end

  def sent_booking_notice_to_restaurant(restaurant_name, email, booking_id)
  #def sent_booking_notice_to_restaurant(restaurant_name, email, booking)
    begin
      @restaurant_name = restaurant_name
      #@booking = booking    *p1
      @booking = Booking.find(booking_id)

      mail(to: email,
           subject: '訂吧通知：即時訂位通知！') do |format|
        format.html { render 'my_mailer/restaurant_booking_notice' }
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/Mailers/my_mailer.rb ,Method:sent_booking_notice_to_restaurant(restaurant_name, email, booking)"
      return false
    end
  end


end
