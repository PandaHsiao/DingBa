class RestaurantSchedule

  def self.send_report
    Rails.logger.error APP_CONFIG['error'] + " Check Schedule"
    now = Time.now
    temp_now = now.strftime("%H:%M")
    sent_date = now.strftime("%H") + ':00'

    if temp_now < '01:00'
      tomorrow = now
    else
      tomorrow = now + 1.day
    end
    tomorrow_begin = tomorrow.strftime("%Y-%m-%d") + " 00:00"
    tomorrow_end = tomorrow.strftime("%Y-%m-%d") + " 23:59"
    tomorrow = Date.parse(tomorrow.to_s)

    result = Restaurant.find_by_sql ['SELECT restaurants.name as rname,restaurants.supply_email, bookings.booking_time, bookings.name, bookings.phone, bookings.email, bookings.remark, bookings.num_of_people FROM restaurants INNER JOIN(bookings) ON (restaurants.id = bookings.restaurant_id AND (restaurants.sent_type =? AND restaurants.sent_date =?) AND bookings.status = ?  AND (bookings.booking_time >= ? AND bookings.booking_time <= ?)) ORDER BY bookings.booking_time','1',sent_date, '0',tomorrow_begin, tomorrow_end]
    #result = Restaurant.find_by_sql ['SELECT restaurants.name as rname,restaurants.supply_email, bookings.booking_time, bookings.name, bookings.phone, bookings.email, bookings.remark, bookings.num_of_people FROM restaurants INNER JOIN(bookings) ON (restaurants.id = bookings.restaurant_id AND (restaurants.sent_type =?) AND bookings.status = ?  AND (bookings.booking_time >= ? AND bookings.booking_time <= ?)) ORDER BY bookings.booking_time','1', '0',tomorrow_begin, tomorrow_end]

    if result.present?
      restaurant_group_books = result.group_by { |x| x[:rname] }

      restaurant_group_books.each do |r|
        if !r[0].nil? && r[1].present?

          temp_books = nil
          temp_books = r[1]
          t_first_books = temp_books.first

          if t_first_books.supply_email.present? && t_first_books.num_of_people.present?
            email = t_first_books.supply_email.split(',')
            if email.count == 1
              email = email[0].split(';')
            end
          end

          if email.present?
            effect_email = []
            email.each do |e|
              if !e.blank? && !(e =~ /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/).blank?
                effect_email.push(e)
              end
            end

            if effect_email.present?
              MyMailer.restaurant_daily_report(tomorrow, r[0], effect_email, r[1]).deliver
            end

            #effect_email.each do |eff|
            #  MyMailer.restaurant_daily_report(tomorrow, r[0], eff, r[1]).deliver
            #end
          end
        end
      end
    end

  end

end