class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from User::Exception, :with => :show_error
  #helper_method :current_user

  ## override devise
  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || sign_in_with_cus(resource_or_scope)
  end

  def after_sign_in_path_for_custom(resource_or_scope, res_url)
    session.delete :res_url
    stored_location_for(resource_or_scope) || sign_in_with_custom(resource_or_scope, res_url)
  end

  def sign_in_with_cus(user)
    begin
      if user.role == '0'
        restaurant_users = RestaurantUser.where(:user_id => user.id) # TODO select restaurant
        restaurant = Restaurant.find(restaurant_users.first.restaurant_id)

        if RestaurantManage.check_restaurant_info(restaurant)
          if RestaurantManage.check_supply_condition(restaurant.id)
            '/restaurant#/calendar/restaurant_month'
          else
            '/restaurant#/restaurant_manage/supply_condition'
          end
        else
          confirmation_getting_started_path
        end
      else
        booker_manage_index_path
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/application_controller.rb  ,Method:sign_in_with_cus(user)"
      home_path
    end
  end

  def sign_in_with_custom(user, res_url)
    begin
      if !res_url.blank?
        @res_url = res_url
        @is_check_login = true

        booking_restaurant_path(:id => @res_url, :is_check_login => @is_check_login)
      else
        if user.role == '0'
          restaurant_users = RestaurantUser.where(:user_id => user.id) # TODO select restaurant
          restaurant = Restaurant.find(restaurant_users.first.restaurant_id)

          if RestaurantManage.check_restaurant_info(restaurant)
            if RestaurantManage.check_supply_condition(restaurant.id)
              '/restaurant#/calendar/restaurant_month'
            else
              '/restaurant#/restaurant_manage/supply_condition'
            end
          else
            confirmation_getting_started_path
          end
        else
          booker_manage_index_path
        end
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/application_controller.rb  ,Method:sign_in_with_custom(user, res_url)"
      home_path
    end
  end

  #protected

  #def current_user=(user)
    #return unless session[:user_id]
    #@current_user ||= User.find_by_id(session[:user_id])
    #@current_user = user
  #end

  def show_error(exception)
    begin
      self.resource = resource_class.new
      clean_up_passwords(resource)

      if !current_user.blank?
        if current_user.role == '0'
          flash.now[:alert] = '發生未知的錯誤！為保安全，我們將您登入狀態清除，請再次登入，謝謝'
          render 'devise/sessions/restaurant_new'
        elsif current_user.role == '1'
          flash.now[:alert] = '發生未知的錯誤！為保安全，我們將您登入狀態清除，請再次登入，謝謝'
          render 'devise/sessions/booker_new'
        end
        return
      else
        redirect_to home_path
      end
    rescue => e
      flash.now[:alert] = '發生未知的錯誤，請與CoDream團隊聯絡，謝謝'
      redirect_to home_path
    end
  end

  def page_not_found
    respond_to do |format|
      #format.html { render template: 'errors/not_found_error', layout: 'layouts/application', status: 404 }
      format.html { render template: 'errors/not_found_error', layout: 'layouts/home_index', status: 404 }
      format.all  { render nothing: true, status: 404 }
    end
  end

  def server_error
    respond_to do |format|
      #format.html { render template: 'errors/internal_server_error', layout: 'layouts/error', status: 500 }
      format.html { render template: 'errors/internal_server_error', layout: 'layouts/home_index', status: 500 }
      format.all  { render nothing: true, status: 500}
    end
  end


  # func ==== Function: auth user and get restaurant
  # ====== Code Check: 2013/12/07 ====== [ panda: TODO: 1.rename @res to @restaurant 2.think the auth solution ]
  # func ==== Function: auth user and get restaurant
  #  Add hack rules  kent 2014/1/19
  # =========================================================================
  def get_restaurant
    begin
      @pay_type = []
      if session[:hack_restaurant_id].blank?
        if current_user.blank?
          flash.now[:alert] = '您還沒登入喔!~~ '
          redirect_to res_session_new_path
        else
          if current_user.role == '0'
            manage_restaurants = RestaurantUser.where(:user_id => current_user.id)
            if !manage_restaurants.blank?         # system error
              target = manage_restaurants.first   # let user choose restaurant to mange, in phase 2

              @restaurant = Restaurant.find(target.restaurant_id)
              @res_url = APP_CONFIG['domain'] + @restaurant.res_url.to_s

              if !@restaurant.pay_type.blank?
                @pay_type = @restaurant.pay_type.split(',')
              end
            end
          elsif current_user.role == '1'
            redirect_to booker_manage_index_path
          end
        end
      else #the user is hacker
        @restaurant = Restaurant.where(:res_url => session[:hack_restaurant_id]).first()
        @res_url = APP_CONFIG['domain'] + @restaurant.res_url.to_s
        if !@restaurant.pay_type.blank?
          @pay_type = @restaurant.pay_type.split(',')
        end
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/calendar_controller.rb  ,Filter:get_restaurant"
      flash.now[:alert] = 'oops! 出現錯誤了!'
      #redirect_to res_session_new_path
    end
  end

end
