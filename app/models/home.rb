class Home
  def self.get_restaurant(restaurant_url)
    begin
      restaurant = Restaurant.new
      restaurant = Restaurant.where(:res_url => restaurant_url).first
      return restaurant
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/Models/home.rb  ,Method:get_restaurant(restaurant_url)"
      restaurant = Restaurant.new
      return restaurant
    end
  end

  def self.get_condition(restaurant, booking_day)
    begin
      #restaurant = restaurant
      booking_condition = BookingCondition.new
      booking_condition.option_of_time = []

      if booking_day.blank?
        booking_day = Date.parse(Time.now.to_s)
      else
        booking_day = Date.parse(booking_day)
      end

      booking_day_begin = Time.parse(booking_day.strftime("%Y-%m-%d") + " 00:00")
      booking_day_end = Time.parse(booking_day.strftime("%Y-%m-%d") + " 23:59")

      conditions = SupplyCondition.where(:restaurant_id => restaurant.id, :status => 't').where('range_end >= ?', booking_day_begin).where('range_begin <= ?', booking_day_begin).order('sequence ASC')

      if conditions.blank?
        booking_condition = BookingCondition.new
        booking_condition.option_of_time = []
        booking_condition.error = true
        booking_condition.message = '目前這個時段，餐廳沒有開放的訂位，請選擇較後面的日期查看喲!'
        return booking_condition
      else
        if conditions.first.is_vacation == 't'
          booking_condition = BookingCondition.new
          booking_condition.option_of_time = []
          booking_condition.error = true
          booking_condition.message = '餐廳今日休假'
          return booking_condition
        end
      end
      #=========================================================================

      effect_condition = nil

      conditions.each do |condition|
        week = condition.available_week.split(',')
        week = week.collect{|e| e.to_i}

        if week.include?(booking_day.wday)
          effect_condition = condition
          break
        end
      end

      if effect_condition.blank?
        booking_condition = BookingCondition.new
        booking_condition.option_of_time = []
        booking_condition.error = true
        booking_condition.message = '目前這個時段，餐廳沒有開放的訂位，請選擇較後面的日期查看喲!'
        return booking_condition
      end
      #=========================================================================

      zones = TimeZone.where(:supply_condition_id => effect_condition.id, :status => 't').order('sequence ASC')

      if zones.blank?
        booking_condition = BookingCondition.new
        booking_condition.option_of_time = []
        booking_condition.error = true
        booking_condition.message = '目前這個時段，餐廳沒有開放的訂位，請選擇較後面的日期查看喲!'
        return booking_condition
      end
      #=========================================================================
      if !restaurant.available_type.blank? && restaurant.available_type == '0'
        limit_hour = restaurant.available_hour
      elsif !restaurant.available_type.blank? && restaurant.available_type == '1'
        limit_day_time = restaurant.available_date
      end

      is_today_or_pass_time = false
      if booking_day <= Date.parse(Time.now.to_s)
        is_today_or_pass_time = true
      end
      #=========================================================================

      booking_condition = BookingCondition.new
      booking_condition.error = false
      booking_condition.option_max_people = []    # [1, 2, 3, 4 ....]
      booking_condition.option_of_people = []     # [zone.each_allow, zone.id, zone.name], [....]
      booking_condition.option_of_time = []       # ['12:00', '12:15' ....]
      booking_condition.option_of_zone = []       # ['zone name', 'zone sequence']

      use_type = -1
      if is_today_or_pass_time && !limit_day_time.blank?
        use_type = 0
        booking_day_begin = Time.parse(booking_day.strftime("%Y-%m-%d") + " 00:00")
        booking_day_end = Time.parse(booking_day.strftime("%Y-%m-%d") + " 23:59")
        temp_bookings = Booking.where(:restaurant_id => restaurant.id).where('status=? OR status=?', '0', '1').where('booking_time >= ?', booking_day_begin).where('booking_time <= ?', booking_day_end).group('booking_time').sum(:num_of_people)

        bookings_of_select_day = []

        temp_bookings.each do |b|
          b[0] = b[0].strftime("%H:%M")       #把相同時段的]人數統計出來
          bookings_of_select_day.push(b)
        end

        zones.each do |z|
          option_of_z_item = []
          option_of_z_item.push(z.name)
          option_of_z_item.push(z.sequence)
          booking_condition.option_of_zone.push(option_of_z_item)
          zone_option_of_people = []
          zone_option_of_people.push(z.each_allow)
          zone_option_of_people.push(z.id)
          zone_option_of_people.push(z.name)
          booking_condition.option_of_people.push(zone_option_of_people)

          temp_begin = z.range_begin.split(':')
          temp_begin_hour = temp_begin[0]
          temp_begin_hour = '24' if temp_begin_hour == '00'
          temp_begin_minute = temp_begin[1]     # if this != 00 then after delete 2

          origin_range_end = z.range_end.split(':')
          origin_end_hour = origin_range_end[0]
          origin_end_hour = '24' if origin_end_hour == '00'
          origin_end_minute = origin_range_end[1]       # if this != 00 then after add 2

          zone_option_of_time = []
          zone_total_people = 0

          temp_begin_hour = temp_begin_hour.to_i
          origin_end_hour = origin_end_hour.to_i
          (temp_begin_hour..origin_end_hour).each do |h|
            h00 = false
            h15 = false
            h30 = false
            h45 = false
            h00_data = nil
            h15_data = nil
            h30_data = nil
            h45_data = nil

            bookings_of_select_day.each do |b|
              if b[0] == h.to_s.rjust(2, '0') + ":00"
                h00 = true
                zone_total_people = zone_total_people + b[1]
                h00_data = [1, h.to_s + ":00", b[1]]
              elsif b[0] == h.to_s.rjust(2, '0') + ":15"
                h15 = true
                zone_total_people = zone_total_people + b[1]
                h15_data = [1, h.to_s + ":15", b[1]]
              elsif b[0] == h.to_s.rjust(2, '0') + ":30"
                h30 = true
                zone_total_people = zone_total_people + b[1]
                h30_data = [1, h.to_s + ":30", b[1]]
              elsif b[0] == h.to_s.rjust(2, '0') + ":45"
                h45 = true
                zone_total_people = zone_total_people + b[1]
                h45_data = [1, h.to_s + ":45", b[1]]
              end
            end

            if h00 == true
              zone_option_of_time.push(h00_data)
            elsif h00 == false
              zone_option_of_time.push([1, h.to_s + ":00", 0])
            end

            if h15 == true
              zone_option_of_time.push(h15_data)
            elsif h15 == false
              zone_option_of_time.push([1, h.to_s + ":15", 0])
            end

            if h30 == true
              zone_option_of_time.push(h30_data)
            elsif h30 == false
              zone_option_of_time.push([1, h.to_s + ":30", 0])
            end

            if h45 == true
              zone_option_of_time.push(h45_data)
            elsif h45 == false
              zone_option_of_time.push([1, h.to_s + ":45", 0])
            end
          end

          if zone_total_people >= z.total_allow
            zone_option_of_time.each do |zt|
              zt[0] = 1
            end
          end

          if temp_begin_minute == '30'
            2.times do
              zone_option_of_time.delete_at(0)
            end
          end

          if origin_end_minute == '00'
            3.times do
              zone_option_of_time.delete_at(zone_option_of_time.length - 1)
            end
          elsif origin_end_minute == '30'
            zone_option_of_time.delete_at(zone_option_of_time.length - 1)
          end

          zone_option_of_time.unshift(z.id, z.fifteen_allow, z.total_allow, zone_total_people, z.each_allow, z.sequence)
          booking_condition.option_of_time.push(zone_option_of_time)
        end

        max_people = 0
        target_index = 0
        booking_condition.option_of_time.length.times do |i|

          if booking_condition.option_of_people[i][0] > max_people
            max_people = booking_condition.option_of_people[i][0]
            target_index = i
          end

          if booking_condition.option_of_time.length != (i + 1)
            booking_condition.option_of_time[i] = booking_condition.option_of_time[i][0..5] + (booking_condition.option_of_time[i][6..booking_condition.option_of_time[i].length] - booking_condition.option_of_time[i + 1][6..booking_condition.option_of_time[i + 1].length])
          end
        end

        booking_condition.option_of_people[target_index][0].times do |i|
          booking_condition.option_max_people.push(i + 1)
        end

        return booking_condition

      elsif !is_today_or_pass_time && !limit_day_time.blank?      # =========================================
                                                                  # booking day not today and use limit_day_time condition
        use_type = 1

        #booking_day_begin = booking_day.strftime("%Y-%m-%d ")
        #booking_day_end = (booking_day + 1.days).strftime("%Y-%m-%d ")
        booking_day_begin = Time.parse(booking_day.strftime("%Y-%m-%d") + " 00:00")
        booking_day_end = Time.parse(booking_day.strftime("%Y-%m-%d") + " 23:59")
        temp_bookings = Booking.where(:restaurant_id => restaurant.id).where('status=? OR status=?', '0', '1').where('booking_time >= ?', booking_day_begin).where('booking_time <= ?', booking_day_end).group('booking_time').sum(:num_of_people)

        bookings_of_select_day = []

        temp_bookings.each do |b|
          b[0] = b[0].strftime("%H:%M")       #把相同時段的]人數統計出來
          bookings_of_select_day.push(b)
        end

        is_tomorrow = false
        if booking_day == Date.parse(Time.now.to_s) + 1.day && Time.now.strftime("%H:%M") >= limit_day_time
          is_tomorrow = true
        end

        zones.each do |z|
          option_of_z_item = []
          option_of_z_item.push(z.name)
          option_of_z_item.push(z.sequence)
          booking_condition.option_of_zone.push(option_of_z_item)

          zone_option_of_people = []
          zone_option_of_people.push(z.each_allow)
          zone_option_of_people.push(z.id)
          zone_option_of_people.push(z.name)
          booking_condition.option_of_people.push(zone_option_of_people)

          temp_begin = z.range_begin.split(':')
          temp_begin_hour = temp_begin[0]
          temp_begin_hour = '24' if temp_begin_hour == '00'
          temp_begin_minute = temp_begin[1]     # if this != 00 then after delete 2

          temp_end = z.range_end.split(':')
          temp_end_hour = temp_end[0]
          temp_end_hour = '24' if temp_end_hour == '00'
          temp_end_minute = temp_end[1]       # if this != 00 then after add 2

          zone_option_of_time = []
          zone_total_people = 0

          temp_begin_hour = temp_begin_hour.to_i
          temp_end_hour = temp_end_hour.to_i
          (temp_begin_hour..temp_end_hour).each do |h|
            h00 = false
            h15 = false
            h30 = false
            h45 = false
            h00_data = nil
            h15_data = nil
            h30_data = nil
            h45_data = nil

            bookings_of_select_day.each do |b|
              if b[0] == h.to_s.rjust(2, '0') + ":00"
                h00 = true
                zone_total_people = zone_total_people + b[1]
                if b[1] >= z.fifteen_allow || is_tomorrow
                  h00_data = [1, h.to_s + ":00", b[1]]              # [[gray],[time],[booking_people]]  1 = gray
                elsif b[1] < z.fifteen_allow
                  h00_data = [0, h.to_s + ":00", b[1]]
                end
              elsif b[0] == h.to_s.rjust(2, '0') + ":15"
                h15 = true
                zone_total_people = zone_total_people + b[1]
                if b[1] >= z.fifteen_allow || is_tomorrow
                  h15_data = [1, h.to_s + ":15", b[1]]
                elsif b[1] < z.fifteen_allow
                  h15_data = [0, h.to_s + ":15", b[1]]
                end
              elsif b[0] == h.to_s.rjust(2, '0') + ":30"
                h30 = true
                zone_total_people = zone_total_people + b[1]
                if b[1] >= z.fifteen_allow || is_tomorrow
                  h30_data = [1, h.to_s + ":30", b[1]]
                elsif b[1] < z.fifteen_allow
                  h30_data = [0, h.to_s + ":30", b[1]]
                end
              elsif b[0] == h.to_s.rjust(2, '0') + ":45"
                h45 = true
                zone_total_people = zone_total_people + b[1]
                if b[1] >= z.fifteen_allow || is_tomorrow
                  h45_data = [1, h.to_s + ":45", b[1]]
                elsif b[1] < z.fifteen_allow
                  h45_data = [0, h.to_s + ":45", b[1]]
                end
              end
            end

            if h00 == true
              zone_option_of_time.push(h00_data)
            elsif h00 == false
              if is_tomorrow
                zone_option_of_time.push([1, h.to_s + ":00", 0])
              else
                zone_option_of_time.push([0, h.to_s + ":00", 0])
              end
            end

            if h15 == true
              zone_option_of_time.push(h15_data)
            elsif h15 == false
              if is_tomorrow
                zone_option_of_time.push([1, h.to_s + ":15", 0])
              else
                zone_option_of_time.push([0, h.to_s + ":15", 0])
              end
            end

            if h30 == true
              zone_option_of_time.push(h30_data)
            elsif h30 == false
              if is_tomorrow
                zone_option_of_time.push([1, h.to_s + ":30", 0])
              else
                zone_option_of_time.push([0, h.to_s + ":30", 0])
              end
            end

            if h45 == true
              zone_option_of_time.push(h45_data)
            elsif h45 == false
              if is_tomorrow
                zone_option_of_time.push([1, h.to_s + ":45", 0])
              else
                zone_option_of_time.push([0, h.to_s + ":45", 0])
              end
            end
          end

          if zone_total_people >= z.total_allow
            zone_option_of_time.each do |zt|
              zt[0] = 1
            end
          end

          if temp_begin_minute == '30'
            2.times do
              zone_option_of_time.delete_at(0)
            end
          end

          if temp_end_minute == '00'
            3.times do
              zone_option_of_time.delete_at(zone_option_of_time.length - 1)
            end
          elsif temp_end_minute == '30'
            zone_option_of_time.delete_at(zone_option_of_time.length - 1)
          end

          zone_option_of_time.unshift(z.id, z.fifteen_allow, z.total_allow, zone_total_people, z.each_allow, z.sequence)
          booking_condition.option_of_time.push(zone_option_of_time)
        end

        max_people = 0
        target_index = 0
        booking_condition.option_of_time.length.times do |i|

          if booking_condition.option_of_people[i][0] > max_people
            max_people = booking_condition.option_of_people[i][0]
            target_index = i
          end

          if booking_condition.option_of_time.length != (i + 1)
            booking_condition.option_of_time[i] = booking_condition.option_of_time[i][0..5] + (booking_condition.option_of_time[i][6..booking_condition.option_of_time[i].length] - booking_condition.option_of_time[i + 1][6..booking_condition.option_of_time[i + 1].length])
          end
        end

        booking_condition.option_of_people[target_index][0].times do |i|
          booking_condition.option_max_people.push(i + 1)
        end

        return booking_condition

      elsif !limit_hour.blank?                  # =========================================
                                                # use pre hour condition
        use_type = 2
        temp_booking_day = booking_day.strftime("%Y-%m-%d ")

        booking_day_begin = Time.parse(booking_day.strftime("%Y-%m-%d") + " 00:00")
        booking_day_end = Time.parse(booking_day.strftime("%Y-%m-%d") + " 23:59")
        temp_bookings = Booking.where(:restaurant_id => restaurant.id).where('status=? OR status=?', '0', '1').where('booking_time >= ?', booking_day_begin).where('booking_time <= ?', booking_day_end).group('booking_time').sum(:num_of_people)

        bookings_of_select_day = []

        temp_bookings.each do |b|
          b[0] = b[0].strftime("%H:%M")       #把相同時段的]人數統計出來
          bookings_of_select_day.push(b)
        end

        zones.each do |z|
          option_of_z_item = []
          option_of_z_item.push(z.name)
          option_of_z_item.push(z.sequence)
          booking_condition.option_of_zone.push(option_of_z_item)
          all_block = false    # add gray
          is_effect = false
          range_begin = Time.parse(temp_booking_day + z.range_begin)
          range_end = Time.parse(temp_booking_day + z.range_end)
          effect_time_begin = Time.now + limit_hour.hour
          if effect_time_begin >= range_begin && effect_time_begin < range_end
            temp_begin_hour = effect_time_begin.strftime("%H")
            temp_begin_minute = effect_time_begin.strftime("%M")
            temp_end_hour = range_end.strftime("%H")
            temp_end_hour = '24' if temp_end_hour == '00'
            temp_end_minute = range_end.strftime("%M")

            is_effect = true
          elsif effect_time_begin < range_begin
            temp_begin_hour = range_begin.strftime("%H")
            temp_begin_minute = range_begin.strftime("%M")
            temp_end_hour = range_end.strftime("%H")
            temp_end_hour = '24' if temp_end_hour == '00'
            temp_end_minute = range_end.strftime("%M")
            is_effect = true
          else
            temp_begin_hour = effect_time_begin.strftime("%H")
            temp_begin_minute = effect_time_begin.strftime("%M")
            all_block = true
            is_effect = true # add gray
          end

          # add gray
          origin_begin_hour = range_begin.strftime("%H")
          origin_begin_minute = range_begin.strftime("%M")
          origin_end_hour = range_end.strftime("%H")
          origin_end_hour = '24' if origin_end_hour == '00'
          origin_end_minute = range_end.strftime("%M")
          # end add ========

          if is_effect
            zone_option_of_people = []
            zone_option_of_people.push(z.each_allow)
            zone_option_of_people.push(z.id)
            zone_option_of_people.push(z.name)
            booking_condition.option_of_people.push(zone_option_of_people)

            zone_option_of_time = []
            zone_total_people = 0
            # add gray
            temp_begin_hour = temp_begin_hour.to_i
            temp_end_hour = temp_end_hour.to_i
            temp_begin_minute = temp_begin_minute.to_i
            origin_begin_hour = origin_begin_hour.to_i
            origin_end_hour = origin_end_hour.to_i
            (origin_begin_hour..origin_end_hour).each do |h|
              if all_block || h < temp_begin_hour
                h00 = false
                h15 = false
                h30 = false
                h45 = false
                h00_data = nil
                h15_data = nil
                h30_data = nil
                h45_data = nil

                bookings_of_select_day.each do |b|
                  if b[0] == (h.to_s.rjust(2, '0') + ":00")
                    h00 = true
                    zone_total_people = zone_total_people + b[1]
                    h00_data = [1, h.to_s + ":00", b[1]]
                  elsif b[0] == (h.to_s.rjust(2, '0') + ":15")
                    h15 = true
                    zone_total_people = zone_total_people + b[1]
                    h15_data = [1, h.to_s + ":15", b[1]]
                  elsif b[0] == (h.to_s.rjust(2, '0') + ":30")
                    h30 = true
                    zone_total_people = zone_total_people + b[1]
                    h30_data = [1, h.to_s + ":30", b[1]]
                  elsif b[0] == (h.to_s.rjust(2, '0') + ":45")
                    h45 = true
                    zone_total_people = zone_total_people + b[1]
                    h45_data = [1, h.to_s + ":45", b[1]]
                  end
                end

                if h00 == true
                  zone_option_of_time.push(h00_data)
                elsif h00 == false
                  zone_option_of_time.push([1, h.to_s + ":00", 0])
                end

                if h15 == true
                  zone_option_of_time.push(h15_data)
                elsif h15 == false
                  zone_option_of_time.push([1, h.to_s + ":15", 0])
                end

                if h30 == true
                  zone_option_of_time.push(h30_data)
                elsif h30 == false
                  zone_option_of_time.push([1, h.to_s + ":30", 0])
                end

                if h45 == true
                  zone_option_of_time.push(h45_data)
                elsif h45 == false
                  zone_option_of_time.push([1, h.to_s + ":45", 0])
                end
              else
                h00 = false
                h15 = false
                h30 = false
                h45 = false
                h00_data = nil
                h15_data = nil
                h30_data = nil
                h45_data = nil
                bookings_of_select_day.each do |b|
                  if b[0] == h.to_s.rjust(2, '0') + ":00"
                    h00 = true
                    zone_total_people = zone_total_people + b[1]
                    if b[1] >= z.fifteen_allow
                      h00_data = [1, h.to_s + ":00", b[1]]              # [[gray],[time],[booking_people]]  1 = gray
                    elsif b[1] < z.fifteen_allow
                      h00_data = [0, h.to_s + ":00", b[1]]
                    end
                  elsif b[0] == h.to_s.rjust(2, '0') + ":15"
                    h15 = true
                    zone_total_people = zone_total_people + b[1]
                    if b[1] >= z.fifteen_allow
                      h15_data = [1, h.to_s + ":15", b[1]]
                    elsif b[1] < z.fifteen_allow
                      h15_data = [0, h.to_s + ":15", b[1]]
                    end
                  elsif b[0] == h.to_s.rjust(2, '0') + ":30"
                    h30 = true
                    zone_total_people = zone_total_people + b[1]
                    if b[1] >= z.fifteen_allow
                      h30_data = [1, h.to_s + ":30", b[1]]
                    elsif b[1] < z.fifteen_allow
                      h30_data = [0, h.to_s + ":30", b[1]]
                    end
                  elsif b[0] == h.to_s.rjust(2, '0') + ":45"
                    h45 = true
                    zone_total_people = zone_total_people + b[1]
                    if b[1] >= z.fifteen_allow
                      h45_data = [1, h.to_s + ":45", b[1]]
                    elsif b[1] < z.fifteen_allow
                      h45_data = [0, h.to_s + ":45", b[1]]
                    end
                  end
                end

                if h == temp_begin_hour && temp_begin_minute > 0
                  zone_option_of_time.push([1, h.to_s + ":00", 0])
                else
                  if h00 == true
                    zone_option_of_time.push(h00_data)
                  elsif h00 == false
                    zone_option_of_time.push([0, h.to_s + ":00", 0])
                  end
                end

                if h == temp_begin_hour && temp_begin_minute >= 15
                  zone_option_of_time.push([1, h.to_s + ":15", 0])
                else
                  if h15 == true
                    zone_option_of_time.push(h15_data)
                  elsif h15 == false
                    zone_option_of_time.push([0, h.to_s + ":15", 0])
                  end
                end

                if h == temp_begin_hour && temp_begin_minute > 30
                  zone_option_of_time.push([1, h.to_s + ":30", 0])
                else
                  if h30 == true
                    zone_option_of_time.push(h30_data)
                  elsif h30 == false
                    zone_option_of_time.push([0, h.to_s + ":30", 0])
                  end
                end

                if h == temp_begin_hour && temp_begin_minute >= 45
                  zone_option_of_time.push([1, h.to_s + ":45", 0])
                else
                  if h45 == true
                    zone_option_of_time.push(h45_data)
                  elsif h45 == false
                    zone_option_of_time.push([0, h.to_s + ":45", 0])
                  end
                end
              end
            end

            if zone_total_people >= z.total_allow
              zone_option_of_time.each do |zt|
                zt[0] = 1
              end
            end

            if temp_begin_minute == 30
              2.times do
                zone_option_of_time.delete_at(0)
              end
            end

            if origin_end_minute == '00'
              3.times do
                zone_option_of_time.delete_at(zone_option_of_time.length - 1)
              end
            elsif origin_end_minute == '30'
              zone_option_of_time.delete_at(zone_option_of_time.length - 1)
            end

            zone_option_of_time.unshift(z.id, z.fifteen_allow, z.total_allow, zone_total_people, z.each_allow, z.sequence)
            booking_condition.option_of_time.push(zone_option_of_time)
          end
        end

        max_people = 0
        target_index = 0
        booking_condition.option_of_time.length.times do |i|

          if booking_condition.option_of_people[i][0] > max_people
            max_people = booking_condition.option_of_people[i][0]
            target_index = i
          end

          if booking_condition.option_of_time.length != (i + 1)
            booking_condition.option_of_time[i] = booking_condition.option_of_time[i][0..5] + (booking_condition.option_of_time[i][6..booking_condition.option_of_time[i].length] - booking_condition.option_of_time[i + 1][6..booking_condition.option_of_time[i + 1].length])
          end
        end

        booking_condition.option_of_people[target_index][0].times do |i|
          booking_condition.option_max_people.push(i + 1)
        end

        return booking_condition
      end

    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/Models/home.rb  ,Method:get_condition(restaurant_url, booking_day)"
      booking_condition = BookingCondition.new
      booking_condition.option_of_time = []
      booking_condition.error = true
      booking_condition.message = '目前這個時段，餐廳沒有開放的訂位，請選擇較後面的日期查看喲!'
      return booking_condition
    end
  end

  def self.save_booking(booker, origin_booking)
    begin
      restaurant = Restaurant.find(origin_booking[:restaurant_id].to_i)
      booker_id = nil

      if booker.id.blank?
        booker_id = nil
      elsif booker.id != origin_booking[:booker_id].to_i       # check null params value can to_i ?
        return {:error => true, :message => '阿! 發生錯誤了! 訂位失敗!'}
      elsif booker.id == origin_booking[:booker_id].to_i
        booker_id = booker.id
      end

      booking_people = origin_booking[:booking_people].to_i
      time_zone_id = origin_booking[:time_zone_id].to_i
      booking_time = Time.parse(origin_booking[:booking_time].to_s)
      day_booking = DayBooking.where(:restaurant_id => restaurant, :day => Date.parse(booking_time.to_s)).first
      time_zone = TimeZone.find(time_zone_id)

      # ========================= validation
      if (booking_people > time_zone.each_allow)
        return {:error => true, :message => '你的訂位人數已經超過該餐廳此時段一次接待客人的數量喔，大量人數訂位請直洽餐廳喔!'}
      end

      if Time.now > booking_time
        return {:error => true, :message => '訂位時間必須大於現在時間喔!'}
      end

      if !day_booking.blank?
        if time_zone.sequence == 0
          if (day_booking.zone1 + booking_people) > time_zone.total_allow
            return {:error => true, :message => '你的訂位人數已經超過該餐廳此時段還可提供訂位的人數，請電話詢問餐廳是否還有位子，以確保權益!'}
          end
        elsif time_zone.sequence == 1
          if (day_booking.zone2 + booking_people) > time_zone.total_allow
            return {:error => true, :message => '你的訂位人數已經超過該餐廳此時段還可提供訂位的人數，請電話詢問餐廳是否還有位子，以確保權益!'}
          end
        elsif time_zone.sequence == 2
          if (day_booking.zone3 + booking_people) > time_zone.total_allow
            return {:error => true, :message => '你的訂位人數已經超過該餐廳此時段還可提供訂位的人數，請電話詢問餐廳是否還有位子，以確保權益!'}
          end
        elsif time_zone.sequence == 3
          if (day_booking.zone4 + booking_people) > time_zone.total_allow
            return {:error => true, :message => '你的訂位人數已經超過該餐廳此時段還可提供訂位的人數，請電話詢問餐廳是否還有位子，以確保權益!'}
          end
        elsif time_zone.sequence == 4
          if (day_booking.zone5 + booking_people) > time_zone.total_allow
            return {:error => true, :message => '你的訂位人數已經超過該餐廳此時段還可提供訂位的人數，請電話詢問餐廳是否還有位子，以確保權益!'}
          end
        elsif time_zone.sequence == 5
          if (day_booking.zone6 + booking_people) > time_zone.total_allow
            return {:error => true, :message => '你的訂位人數已經超過該餐廳此時段還可提供訂位的人數，請電話詢問餐廳是否還有位子，以確保權益!'}
          end
        end
      end

      time_fifteen_sum = Booking.where(:restaurant_id => restaurant.id).where(:booking_time => Date.parse(booking_time.to_s)).sum(:num_of_people)

      if (time_fifteen_sum + booking_people) > time_zone.fifteen_allow
        return {:error => true, :message => '你的訂位人數已經超過該餐廳此時段還可提供訂位的人數，請電話詢問餐廳是否還有位子，以確保權益!'}
      end
      # ========================= end of validation

      if restaurant.front_cover == '1'
        restaurant_pic = restaurant.pic_name1
      elsif restaurant.front_cover == '2'
        restaurant_pic = restaurant.pic_name2
      elsif restaurant.front_cover == '3'
        restaurant_pic = restaurant.pic_name3
      elsif restaurant.front_cover == '4'
        restaurant_pic = restaurant.pic_name4
      elsif restaurant.front_cover == '5'
        restaurant_pic = restaurant.pic_name5
      end

      Booking.transaction do
        booking = Booking.new
        booking.user_id = booker_id
        booking.restaurant_id = restaurant.id
        booking.res_url = restaurant.res_url
        booking.restaurant_name = restaurant.name
        booking.restaurant_address = "#{restaurant.city} #{restaurant.area} #{restaurant.address}"
        booking.booking_time = booking_time
        booking.num_of_people = booking_people
        booking.name = origin_booking[:booker_name]
        booking.phone = origin_booking[:booker_phone]
        booking.email = origin_booking[:booker_email]
        booking.remark = origin_booking[:remark]
        booking.status = '0'
        booking.restaurant_pic = restaurant_pic
        booking.cancel_key = SecureRandom.hex(20)
        booking.save

        time_zone = TimeZone.find( origin_booking[:time_zone_id].to_i)

        day_booking = DayBooking.where(:restaurant_id => restaurant, :day => Date.parse(booking.booking_time.to_s)).first

        if day_booking.blank?
          day_booking = DayBooking.new
          day_booking.restaurant_id = restaurant.id
          day_booking.day = Date.parse(booking.booking_time.to_s)
          day_booking.zone1 = 0
          day_booking.zone2 = 0
          day_booking.zone3 = 0
          day_booking.zone4 = 0
          day_booking.zone5 = 0
          day_booking.zone6 = 0
          day_booking.other = 0
        end

        if time_zone.sequence == 0
          day_booking.zone1 = day_booking.zone1 + booking.num_of_people
        elsif time_zone.sequence == 1
          day_booking.zone2 = day_booking.zone2 + booking.num_of_people
        elsif time_zone.sequence == 2
          day_booking.zone3 = day_booking.zone3 + booking.num_of_people
        elsif time_zone.sequence == 3
          day_booking.zone4 = day_booking.zone4 + booking.num_of_people
        elsif time_zone.sequence == 4
          day_booking.zone5 = day_booking.zone5 + booking.num_of_people
        elsif time_zone.sequence == 5
          day_booking.zone6 = day_booking.zone6 + booking.num_of_people
        end
        day_booking.save

        temp_phone = booking.phone
        if !booking.email.blank? && !(booking.email =~ /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/).blank?
          booking.phone = nil
          booking.res_url = APP_CONFIG['domain'] + "#{booking.res_url}"
          booking.cancel_key = APP_CONFIG['domain_clear'] + "home/cancel_booking_by_email?cancel_key=" + "#{booking.cancel_key}"  + "&booking_key=" + "#{booking.id}"

          #send_mail_result = MyMailer.booking_success(booking.email, booking).deliver   # default
          #send_mail_result = MyMailer.booking_success(booking.id).deliver               # resque
          send_mail_result = MyMailer.delay_for(1.second).booking_success(booking.id, APP_CONFIG['domain'], APP_CONFIG['domain_clear'])    # sidekiq
          # Send mail fail may be the email problem, check time out
          # send_mail_result = MyMailer.delay(run_at: 1.minutes.from_now).booking_success(booking.email, booking)
        end

        if restaurant.sent_type == '0'
          if restaurant.supply_email.present?
            email = restaurant.supply_email.split(',')
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

            booking.phone = temp_phone

            if effect_email.present?
              #MyMailer.sent_booking_notice_to_restaurant(restaurant.name, effect_email, booking).deliver
              MyMailer.delay_for(1.second).sent_booking_notice_to_restaurant(restaurant.name, effect_email, booking.id)    # sidekiq
            end
            #effect_email.each do |eff|
            #  MyMailer.sent_booking_notice_to_restaurant(restaurant.name, eff, booking).deliver
            #end
          end
        end

        has_mail = false
        #if !send_mail_result.blank?
        #  has_mail = true
        #end

        if booking.num_of_people > 1
          booking_notice_type = 'multi'
        elsif booking.num_of_people == 1
          booking_notice_type = 'one'
        end
        return {:success => true, :data => '訂位成功!', :booking_id => booking.id, :booking_notice_type => booking_notice_type, :has_mail => has_mail}
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/Models/home.rb  ,Method:save_booking(user_id, booking)"
      return {:error => true, :message => '阿! 發生錯誤了! 訂位失敗!'}
    end
  end
end