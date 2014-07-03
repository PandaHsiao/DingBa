class CalendarController < ApplicationController
  before_action :get_restaurant, :only => [:restaurant_month, :restaurant_day]

  # ====== Code Check: 2013/12/07 ====== [ panda: TODO: wait Front-end engineering ]
  # GET ==== Function: show month calendar
  # =========================================================================
  def restaurant_month
    if !check_step_image(@restaurant)
      return
    end

    year = params[:year]
    month = params[:month]
    result = Calendar.get_restaurant_month(year, month, @restaurant.id)

    @year = result[:year]
    @month = result[:month]
    @books = result[:books]
    @calendar_data = result[:calendar_data]
    @id_with_name = result[:id_with_name]

    #render 'calendar/restaurant_month', :layout => false
    render json: {:success => true, :attachmentPartial => render_to_string('calendar/restaurant_month', :layout => false) }
  end

  # ====== Code Check: 2013/12/07 ====== [ panda: ok ]
  # GET ==== Function: show day booking
  # =========================================================================
  def restaurant_day
    if !check_step_image(@restaurant)
      return
    end

    @select_date = params[:select_date]
    @select_date = Time.now.to_s if @select_date.blank?
    @zones_books = RestaurantManage.get_day_books(@restaurant.id, @select_date)
    @select_date = @select_date.to_date
    #render 'restaurant_manage/_day_booking', :layout => false
    render json: {:success => true, :step => '3', :attachmentPartial => render_to_string('restaurant_manage/_day_booking', :layout => false )}
  end



  def check_step_image(restaurant)
    if !RestaurantManage.check_restaurant_info(restaurant)
      render json: {:error => true, :message => '餐廳資料,必填欄位完善才能進行下一步喔!', :step => '1', :url => '/restaurant_manage/restaurant_info', :attachmentPartial => render_to_string('restaurant_manage/restaurant_info', :layout => false ) }
      return false
    end

    if !RestaurantManage.check_restaurant_image(restaurant)
      render json: {:error => true, :message => '餐廳圖片,必填至少上傳一張才能進行下一步喔!', :step => '2', :url => '/restaurant_manage/restaurant_image', :attachmentPartial => render_to_string('restaurant_manage/restaurant_image', :layout => false ) }
      return false
    end

    return true
  end

end