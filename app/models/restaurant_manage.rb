class RestaurantManage

  def self.check_restaurant_info(restaurant)
    if restaurant.blank?
      return false
    end

    if restaurant.name.blank? ||
        restaurant.address.blank? ||
        restaurant.business_hours.blank? ||
        restaurant.price_from.blank? ||
        restaurant.price_to.blank? ||
        restaurant.supply_person.blank? ||
        restaurant.supply_email.blank?
      return false
    else
      return true
    end
  end

  def self.check_restaurant_image(restaurant)
    if restaurant.blank?
      return false
    end

    if restaurant.pic_name1.blank? &&
        restaurant.pic_name2.blank? &&
        restaurant.pic_name3.blank? &&
        restaurant.pic_name4.blank? &&
        restaurant.pic_name5.blank?
      return false
    else
      return true
    end
  end

  def self.check_supply_condition(restaurant_id)
    effect_conditions = SupplyCondition.where(:restaurant_id => restaurant_id, :status => 't').where('range_end >= ?', Time.now)

    if effect_conditions.blank?
      return false
    else
      return true
    end
  end

  def self.is_numeric?(obj)
    obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

  def self.restaurant_info_save(origin_restaurant)
    begin
      restaurant = Restaurant.find(origin_restaurant[:id].to_i)
      restaurant.name = origin_restaurant[:name].strip
      restaurant.phone = origin_restaurant[:phone].strip
      restaurant.city = origin_restaurant[:city]
      restaurant.area = origin_restaurant[:area]
      restaurant.address = origin_restaurant[:address].strip
      restaurant.res_type = origin_restaurant[:res_type]
      restaurant.feature = origin_restaurant[:feature].strip
      pay_type = [origin_restaurant[:pay_type_cash], origin_restaurant[:pay_type_CreditCard], origin_restaurant[:pay_type_EasyCard]].join(',')
      restaurant.pay_type = pay_type

      price_from = origin_restaurant[:price_from].strip
      price_to = origin_restaurant[:price_to].strip

      if is_numeric?(price_from) && is_numeric?(price_to)
        price_from = price_from.to_i
        price_to = price_to.to_i
        if price_to >= price_from && price_to >= 0 && price_from >= 0
          restaurant.price_from = price_from
          restaurant.price_to = price_to
        else
          return {:error => true, :message => '價格欄位資料錯誤，請確定為大於零整數'}
        end
      else
        return {:error => true, :message => '價格欄位資料錯誤，請確定為大於零整數'}
      end

      restaurant.business_hours = origin_restaurant[:business_hours].strip
      restaurant.supply_person = origin_restaurant[:supply_person].strip

      temp_email = origin_restaurant[:supply_email].strip
      email = nil
      if !temp_email.blank?
        email = temp_email.split(',')
        if email.count == 1
          email = email[0].split(';')
        end
      end

      email.each do |e|
        if !e.blank? && !(e =~ /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/).blank?
        else
          return {:error => true, :message => '供位 E-Mail 格式錯誤!'}
        end
      end

      restaurant.supply_email = temp_email

      restaurant.url1 = get_http_string(origin_restaurant[:url1]).strip
      restaurant.url2 = get_http_string(origin_restaurant[:url2]).strip
      restaurant.url3 = get_http_string(origin_restaurant[:url3]).strip
      restaurant.info_url1 = origin_restaurant[:info_url1].strip
      restaurant.info_url2 = origin_restaurant[:info_url2].strip
      restaurant.info_url3 = origin_restaurant[:info_url3].strip

      if restaurant.save
        return {:success => true, :data => '餐廳資訊儲存成功，自動導頁到下個步驟'}
      else
        error_message = restaurant.errors.first[1]
        return {:error => true, :message => error_message}
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:res_info_save(restaurant_info)"
      return {:error => true, :message => '阿! 發生錯誤了! 餐廳資訊 儲存失敗!'}
    end
  end

  def self.get_http_string(url)
    taget_url = url

    if taget_url.length > 1 && (taget_url[0..6] == 'http://' || taget_url[0..7] == 'https://')
    elsif taget_url.length > 1
      taget_url = "http://#{taget_url}"
    end

    return taget_url
  end

  def self.upload_img(restaurant, qqfile, data)
    begin
      path = File.expand_path("./public/res/#{restaurant.id}/images/", Rails.root)
      now = Time.now.to_i.to_s + Random.rand(9999).to_s
      FileUtils.mkdir_p(path) unless File.directory?(path)
      ex_name = qqfile.split('.').pop
      filename = "#{now}.#{ex_name}"

      change_booking_pic_name = false
      if restaurant.pic_name1.blank?
        restaurant.pic_name1 = filename
        if restaurant.front_cover.blank?
          restaurant.front_cover = '1'
          change_booking_pic_name = true
        end
      elsif restaurant.pic_name2.blank?
        restaurant.pic_name2 = filename
        if restaurant.front_cover.blank?
          restaurant.front_cover = '2'
          change_booking_pic_name = true
        end
      elsif restaurant.pic_name3.blank?
        restaurant.pic_name3 = filename
        if restaurant.front_cover.blank?
          restaurant.front_cover = '3'
          change_booking_pic_name = true
        end
      elsif restaurant.pic_name4.blank?
        restaurant.pic_name4 = filename
        if restaurant.front_cover.blank?
          restaurant.front_cover = '4'
          change_booking_pic_name = true
        end
      elsif restaurant.pic_name5.blank?
        restaurant.pic_name5 = filename
        if restaurant.front_cover.blank?
          restaurant.front_cover = '5'
          change_booking_pic_name = true
        end
      else
        return {:error => true, :message => '只能上傳五張圖片!'}
      end

      Restaurant.transaction do
        if !restaurant.save
          error_message = restaurant.errors.first[1]
          return {:error => true, :message => error_message}
        end

        if change_booking_pic_name
          effect_booking = Booking.where(:restaurant_id => restaurant.id)

          effect_booking.each do |eb|
            eb.restaurant_pic = filename
            eb.save
          end
        end

        fullpath = File.expand_path(filename, path)
        File.open(fullpath, 'wb'){ |file| file.write(data) }

        image_path = {}
        image_path[1] = "res/#{restaurant.id}/images/" + restaurant.pic_name1 if !restaurant.pic_name1.blank?
        image_path[2] = "res/#{restaurant.id}/images/" + restaurant.pic_name2 if !restaurant.pic_name2.blank?
        image_path[3] = "res/#{restaurant.id}/images/" + restaurant.pic_name3 if !restaurant.pic_name3.blank?
        image_path[4] = "res/#{restaurant.id}/images/" + restaurant.pic_name4 if !restaurant.pic_name4.blank?
        image_path[5] = "res/#{restaurant.id}/images/" + restaurant.pic_name5 if !restaurant.pic_name5.blank?

        return {:success => true, :image_path => image_path, :cover_id => restaurant.front_cover }
      end
    rescue Exception => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:upload_img(restaurant, qqfile, data)"
      return {:error => true, :message => '阿! 發生錯誤了! 上傳失敗!'}
    end
  end

  def self.image_cover_save(restaurant, cover_id)
    begin
      if (cover_id == '1' && restaurant.pic_name1.blank?) ||
          (cover_id == '2' && restaurant.pic_name2.blank?) ||
          (cover_id == '3' && restaurant.pic_name3.blank?) ||
          (cover_id == '4' && restaurant.pic_name4.blank?) ||
          (cover_id == '5' && restaurant.pic_name5.blank?)

        return {:error => true, :message => '有圖片才能設為封面喔!'}
      else
        restaurant.front_cover = cover_id

        if restaurant.save
          return {:success => true, :data => '封面設定完畢!'}
        else
          error_message = restaurant.errors.first[1]
          return {:error => true, :message => error_message}
        end
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:img_cover_save(restaurant, cover_id)"
      return {:error => true, :message => '阿! 發生錯誤了! 設定失敗!'}
    end
  end

  def self.image_destroy(restaurant, pic_id)
    begin
      pic_name = nil
      if pic_id == '1'
        pic_name = restaurant.pic_name1
        restaurant.pic_name1 = nil
      elsif pic_id == '2'
        pic_name = restaurant.pic_name2
        restaurant.pic_name2 = nil
      elsif pic_id == '3'
        pic_name = restaurant.pic_name3
        restaurant.pic_name3 = nil
      elsif pic_id == '4'
        pic_name = restaurant.pic_name4
        restaurant.pic_name4 = nil
      elsif pic_id == '5'
        pic_name = restaurant.pic_name5
        restaurant.pic_name5 = nil
      end

      change_pic_name = nil
      if !pic_name.blank?
        #if restaurant.front_cover == pic_id
        if !restaurant.pic_name1.blank?
          change_pic_name = restaurant.pic_name1
          restaurant.front_cover = '1'
        elsif !restaurant.pic_name2.blank?
          change_pic_name = restaurant.pic_name2
          restaurant.front_cover = '2'
        elsif !restaurant.pic_name3.blank?
          change_pic_name = restaurant.pic_name3
          restaurant.front_cover = '3'
        elsif !restaurant.pic_name4.blank?
          change_pic_name = restaurant.pic_name4
          restaurant.front_cover = '4'
        elsif !restaurant.pic_name5.blank?
          change_pic_name = restaurant.pic_name5
          restaurant.front_cover = '5'
        else
          restaurant.front_cover = nil
        end
        #end

        Restaurant.transaction do
          restaurant.save
          effect_booking = Booking.where(:restaurant_id => restaurant.id, :restaurant_pic => pic_name)

          effect_booking.each do |eb|
            eb.restaurant_pic = change_pic_name
            eb.save
          end

          path = File.expand_path("./public/res/#{restaurant.id}/images/", Rails.root)
          File.delete(path + '/' + pic_name)

          image_path = {}
          image_path[1] = "res/#{restaurant.id}/images/" + restaurant.pic_name1 if !restaurant.pic_name1.blank?
          image_path[2] = "res/#{restaurant.id}/images/" + restaurant.pic_name2 if !restaurant.pic_name2.blank?
          image_path[3] = "res/#{restaurant.id}/images/" + restaurant.pic_name3 if !restaurant.pic_name3.blank?
          image_path[4] = "res/#{restaurant.id}/images/" + restaurant.pic_name4 if !restaurant.pic_name4.blank?
          image_path[5] = "res/#{restaurant.id}/images/" + restaurant.pic_name5 if !restaurant.pic_name5.blank?

          return {:success => true, :data => '刪除成功!', :image_path => image_path, :cover_id => restaurant.front_cover }
        end
      else
        return {:error => true, :message => '沒有圖片~ 無法刪除!'}
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:img_destroy(restaurant, pic_id)"
      return {:error => true, :message => '阿! 發生錯誤了! 刪除失敗!'}
    end
  end

  def self.supply_condition_save_check(origin_zones)
    have_one_enable = false
    origin_zones.length.times do |i|
      temp_max_zone = origin_zones[i]

      if !temp_max_zone[:enable].blank?
        have_one_enable = true
      end

      if !temp_max_zone[:enable].blank? && (temp_max_zone[:total_allow].to_i < temp_max_zone[:fifteen_allow].to_i) || (temp_max_zone[:total_allow].to_i < temp_max_zone[:each_allow].to_i) || (temp_max_zone[:fifteen_allow].to_i < temp_max_zone[:each_allow].to_i)
        return {:error => true, :message => '總供位必須大於15分鐘供位和單次供位人數!'}
      end

      origin_zones.length.times do |j|
        if j != i
          if !temp_max_zone[:enable].blank? && temp_max_zone[:time_begin] == temp_max_zone[:time_end]
            if !origin_zones[j][:enable].blank? && (origin_zones[j][:time_begin] <= temp_max_zone[:time_begin] && origin_zones[j][:time_end] >= temp_max_zone[:time_end])
              return {:error => true, :message => '時段不能重疊喔!'}
            end
          elsif !temp_max_zone[:enable].blank?
            if !origin_zones[j][:enable].blank? && (origin_zones[j][:time_begin] < temp_max_zone[:time_end] && origin_zones[j][:time_end] >= temp_max_zone[:time_end])
              return {:error => true, :message => '時段不能重疊喔!'}
            end
          end
        end
      end
    end

    return {:error => false, :have_one_enable => have_one_enable }
  end

  def self.supply_condition_create(restaurant_id, origin_condition, origin_zones)
    begin
      if origin_condition[:week1].blank? && origin_condition[:week2].blank? && origin_condition[:week3].blank? && origin_condition[:week4].blank? && origin_condition[:week5].blank? && origin_condition[:week6].blank? && origin_condition[:week7].blank?
        return {:error => true, :message => '星期幾至少要選一個!'}
      end

      result = supply_condition_save_check(origin_zones)

      if result[:error] == true
        return result
      else
        if !result[:have_one_enable]
          return {:error => true, :message => '至少要啟用一個時段喔!'}
        end
      end

      SupplyCondition.transaction do
        target_condition = SupplyCondition.new

        max_sequence = SupplyCondition.maximum(:sequence)
        max_sequence.blank? ? max_sequence = 1 : max_sequence = max_sequence + 1

        # why set sequence in this area => because the supply_condition_save method have multi usage, and they don't set sequence
        target_condition.sequence = max_sequence
        target_condition.sequence.blank?  ? target_condition.sequence = 1 : target_condition.sequence
        condition_id = supply_condition_save(origin_condition, restaurant_id, target_condition)

        if condition_id.blank?
          return {:error => true, :message => '阿! 發生錯誤了! 新增失敗!'}
        end

        # why init target_zones in this area => because the time_zone_save method have multi usage, and they don't init target_zones
        target_zones = []
        6.times do
          target_zones.push(TimeZone.new)
        end
        time_zone_save(origin_zones, condition_id, target_zones)
        calculate_day_booking_part(restaurant_id, condition_id)

        return {:success => true, :data => '新增供位條件成功!'}
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:supply_condition_create(restaurant_id, origin_condition, origin_zones)"
      return {:error => true, :message => '阿! 發生錯誤了! 新增失敗!'}
    end
  end

  def self.supply_condition_update(restaurant_id, origin_condition, origin_zones)
    begin

      if origin_condition[:is_vacation].blank?
        result = supply_condition_save_check(origin_zones)

        target_condition = SupplyCondition.find(origin_condition[:id].to_i)

        if target_condition.is_special.blank? && origin_condition[:week1].blank? && origin_condition[:week2].blank? && origin_condition[:week3].blank? && origin_condition[:week4].blank? && origin_condition[:week5].blank? && origin_condition[:week6].blank? && origin_condition[:week7].blank?
          return {:error => true, :message => '星期幾至少要選一個!'}
        end

        if result[:error] == true
          return result
        else
          if !result[:have_one_enable] #&& !target_condition.is_special.blank? && target_condition.is_special != 't'
            return {:error => true, :message => '至少要啟用一個時段喔!'}
          end
        end
      else
        target_condition = SupplyCondition.find(origin_condition[:id].to_i)
      end

      #have_one_enable = false
      #origin_zones.length.times do |i|
      #  temp_max_zone = origin_zones[i]
      #
      #  if !temp_max_zone[:enable].blank?
      #    have_one_enable = true
      #  end
      #
      #  if !temp_max_zone[:enable].blank? && (temp_max_zone[:total_allow].to_i < temp_max_zone[:fifteen_allow].to_i) || (temp_max_zone[:total_allow].to_i < temp_max_zone[:each_allow].to_i) || (temp_max_zone[:fifteen_allow].to_i < temp_max_zone[:each_allow].to_i)
      #    return {:error => true, :message => '總供位必須大於15分鐘供位和單次供位人數!'}
      #  end
      #
      #  origin_zones.length.times do |j|
      #    if j != i
      #      if !temp_max_zone[:enable].blank? && temp_max_zone[:time_begin] == temp_max_zone[:time_end]
      #        if !origin_zones[j][:enable].blank? && (origin_zones[j][:time_begin] <= temp_max_zone[:time_begin] && origin_zones[j][:time_end] >= temp_max_zone[:time_end])
      #          return {:error => true, :message => '時段不能重疊喔!'}
      #        end
      #      elsif !temp_max_zone[:enable].blank?
      #        if !origin_zones[j][:enable].blank? && (origin_zones[j][:time_begin] < temp_max_zone[:time_end] && origin_zones[j][:time_end] >= temp_max_zone[:time_end])
      #          return {:error => true, :message => '時段不能重疊喔!'}
      #        end
      #      end
      #    end
      #  end
      #end
      #
      #target_condition = SupplyCondition.find(origin_condition[:id].to_i)
      #if !have_one_enable && target_condition.is_special != 't'
      #  return {:error => true, :message => '至少要啟用一個時段喔!'}
      #end

      SupplyCondition.transaction do
        condition_id = supply_condition_save(origin_condition, restaurant_id, target_condition)

        if condition_id.blank?
          return {:error => true, :message => '阿! 發生錯誤了! 修改失敗!'}
        end

        zones = TimeZone.where(:supply_condition_id => origin_condition[:id].to_i).order('sequence ASC')
        time_zone_save(origin_zones, condition_id, zones)
        calculate_day_booking_part(restaurant_id, condition_id)

        return {:success => true, :data => '修改成功!'}
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:supply_condition_update(restaurant_id, origin_condition, origin_zones)"
      return {:error => true, :message => '阿! 發生錯誤了! 修改失敗!'}
    end
  end

  def self.supply_condition_save(origin_condition, restaurant_id, target_condition)
    # don't catch this method error , transaction issue
    target_condition.restaurant_id = restaurant_id
    target_condition.name = origin_condition[:name]
    target_condition.is_vacation = origin_condition[:is_vacation]
    if target_condition.is_special == 't'
      target_condition.range_begin = origin_condition[:range_begin]
      target_condition.range_end = origin_condition[:range_begin] + " 23:59"
    else
      target_condition.range_begin = origin_condition[:range_begin]
      target_condition.range_end = origin_condition[:range_end] + " 23:59"
      target_condition.available_week = "#{origin_condition[:week1]},#{origin_condition[:week2]},#{origin_condition[:week3]},#{origin_condition[:week4]},#{origin_condition[:week5]},#{origin_condition[:week6]},#{origin_condition[:week7]}"
    end
    target_condition.status = 't'   # t = enable ,f = disable
    target_condition.save
    return target_condition.id
  end

  def self.time_zone_save(origin_zones, condition_id, target_zones)
    #TODO: batch save
    # don't catch this method error , transaction issue
    zones = []
    origin_zones.each_with_index do |origin_zone, index|
      zone = target_zones[index]
      zone.supply_condition_id = condition_id
      zone.sequence = index
      origin_zone[:enable].blank? ? zone.status = 'f' : zone.status = 't'
      zone.name = origin_zone[:name]
      zone.range_begin = origin_zone[:time_begin]
      zone.range_end = origin_zone[:time_end]
      zone.total_allow = origin_zone[:total_allow]
      zone.each_allow = origin_zone[:each_allow]
      zone.fifteen_allow = origin_zone[:fifteen_allow]
      zones.push(zone)
    end

    zones.length.times do |i|
      zones.length.times do |j|
        temp_max_zone = zones[j]
        if !zones[j + 1].blank?
          temp_begin = zones[j + 1].range_begin.split(':')
          if zones[j + 1].range_begin < zones[j].range_begin
            if temp_begin[0] != '00'
              temp_max_zone = zones[j]
              zones[j]= zones[j + 1]
              zones[j + 1] = temp_max_zone
            end
          end
        end
      end
    end

    #zone_array = []
    zones.each_with_index do |zone, index|
      zone.sequence = index
      zone.save

      #x = zone.attributes
      #zone_array.push(x)
    end

    #TimeZone.create(zone_array)

    return true
  end

  def self.destroy_condition(condition_id, restaurant_id)
    if !condition_id.blank?
      begin
        condition_id = condition_id.to_i
        SupplyCondition.transaction do
          SupplyCondition.find(condition_id).destroy
          TimeZone.where(:supply_condition_id => condition_id).destroy_all
          calculate_day_booking_all(restaurant_id)
          return {:success => true, :data => '刪除成功!' }
        end
      rescue => e
        Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:destroy_condition(condition_id)"
        return {:error => true, :message => '阿! 發生錯誤了! 刪除失敗!'}
      end
    else
      return {:error => true, :message => '阿! 發生錯誤了! 找不到此條件!'}
    end
  end

  def self.special_create(origin_zones, special_day, restaurant_id, is_vacation, condition_name)
    begin
      if is_vacation.blank?
        result = supply_condition_save_check(origin_zones)

        if result[:error] == true
          return result
        else
          if !result[:have_one_enable]
            return {:error => true, :message => '至少要啟用一個時段喔!'}
          end
        end
      end

      special_day_begin = Time.parse(special_day)
      special_day_end = special_day_begin.strftime("%Y-%m-%d") + " 23:59"
      origin = SupplyCondition.where(:restaurant_id => restaurant_id, :is_special => 't').where('range_begin >= ?', special_day_begin).where('range_end <= ?', special_day_end)

      origin_id = 0
      is_origin = false
      if !origin.blank?
        origin_id = origin.first.id
        is_origin = true
      end

      target_zones = []
      6.times do
        target_zones.push(TimeZone.new)
      end

      if origin_id != 0
        condition_id = origin_id
      else
        condition_id = SupplyCondition.maximum(:id) + 1
      end

      SupplyCondition.transaction do
        # destroy orign
        if is_origin == true
          origin.first.destroy
          TimeZone.where(:supply_condition_id => origin.first.id).destroy_all
        end

        # special day condition
        condition = SupplyCondition.new
        condition.id = condition_id
        condition.restaurant_id = restaurant_id
        #condition.name = Date.parse(special_day_begin.to_s).to_s
        condition.name = condition_name.strip
        condition.status = 't'
        condition.range_begin = special_day_begin
        condition.range_end = special_day_end
        condition.available_week = '0,1,2,3,4,5,6'
        condition.sequence = 0
        condition.is_special = 't'
        condition.is_vacation = is_vacation
        condition.save

        # special time zone save
        time_zone_save(origin_zones, condition_id, target_zones)
        calculate_day_booking_special(restaurant_id, condition_id)
        return {:success => true, :data => '新增特定日供位條件成功!'}
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:special_create(origin_zones, special_day, restaurant_id)"
      return {:error => true, :message => '阿! 發生錯誤了! 設定失敗!'}
    end
  end

  def self.condition_state_save(data, restaurant)
    begin
      SupplyCondition.transaction do
        # parse json
        data_parsed = JSON.parse(data)

        # split id and status
        condition_id_list = data_parsed['id_list']
        condition_status_list = data_parsed['status_list']

        # split each element
        condition_id_list = condition_id_list.split(',')
        condition_status_list = condition_status_list.split(',')

        # get condition length
        condition_length = condition_id_list.length

        # validation data
        if condition_length != condition_status_list.length
          #return nil  not just condition length
          # TODO ajax data error, hacker condition
        end

        # get this restaurant all condition
        conditions = SupplyCondition.where(:restaurant_id => restaurant.id.to_i)

        # validation data
        if condition_length != conditions.length
          #return nil
          # TODO ajax data error, hacker condition
        end

        # string to integer
        condition_id_list = condition_id_list.collect{|i| i.to_i}

        # save change
        conditions.each do |c|
          condition_id_list.each_with_index do |cid, index|
            if c.id == cid
              c.sequence = index
              c.status = condition_status_list[index]
              c.save
              break
            end
          end
        end

        # save reserve data
        restaurant.available_hour = data_parsed['reserve_hour'].to_i
        restaurant.available_date = data_parsed['reserve_previous_hour']
        restaurant.available_type = data_parsed['reserve_type']
        restaurant.sent_date = data_parsed['sent_hour']
        restaurant.sent_type = data_parsed['sent_type']
        restaurant.save

        calculate_day_booking_all(restaurant.id.to_i)

        return conditions
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:condition_state_save(data, restaurant)"
      return nil
    end
  end

  def self.get_time_zones(condition_id)
    time_zones = []
    if condition_id.blank? || condition_id == '0'   # active record default id start is 1, so i can use 0 to mark no condition
      zone1 = TimeZone.new
      zone1.name = '早餐'
      zone1.range_begin = '06:00'
      zone1.range_end = '10:00'
      time_zones.push(zone1)

      zone2 = TimeZone.new
      zone2.name = '早午餐'
      zone2.range_begin = '10:00'
      zone2.range_end = '12:00'
      time_zones.push(zone2)

      zone3 = TimeZone.new
      zone3.name = '午餐'
      zone3.range_begin = '12:00'
      zone3.range_end = '14:00'
      time_zones.push(zone3)

      zone4 = TimeZone.new
      zone4.name = '下午茶'
      zone4.range_begin = '14:00'
      zone4.range_end = '17:00'
      time_zones.push(zone4)

      zone5 = TimeZone.new
      zone5.name = '晚餐'
      zone5.range_begin = '17:00'
      zone5.range_end = '21:00'
      time_zones.push(zone5)

      zone6 = TimeZone.new
      zone6.name = '宵夜'
      zone6.range_begin = '21:00'
      zone6.range_end = '24:00'
      time_zones.push(zone6)
    else
      zones = TimeZone.where(:supply_condition_id => condition_id.to_i).order('sequence')  # if add .to_i must add begin recure
      zones.each do |z|
        time_zones.push(z)
      end
    end
    return time_zones
  end

  def self.get_day_books(restaurant_id, special_day)
    begin
      special_day = Date.parse(special_day)
      special_day_begin = Time.parse(special_day.strftime("%Y-%m-%d") + " 00:00")
      special_day_end = Time.parse(special_day.strftime("%Y-%m-%d") + " 23:59")

      # FIX  where below
      day_books = Booking.where(:restaurant_id => restaurant_id).where('booking_time >= ?', special_day_begin).where('booking_time <= ?', special_day_end).order('booking_time ASC')

      if !day_books.blank?
        conditions = SupplyCondition.where(:restaurant_id => restaurant_id).where(:status => 't').where('range_begin <= ?', special_day_begin).where('range_end >= ?',special_day_begin).order('sequence ASC')

        if conditions.blank? || conditions.first.is_vacation == 't'
          zones_books = []
          zone_booking = ZoneBooking.new
          zone_booking.name = '今日訂位資訊'
          zone_booking.books = day_books
          zones_books.push(zone_booking)
          return zones_books
        end

        effect_conditions = nil
        conditions.each do |c|
          if c.available_week.split(',').include?(special_day.wday.to_s)
            effect_conditions = c
            break;
          end
        end

        zones_books = []
        if effect_conditions.blank?
          if !day_books.blank? && day_books.length > 0
            zone_booking = ZoneBooking.new
            zone_booking.name = '其他時段'
            zone_booking.books = day_books
            zones_books.push(zone_booking)
            return zones_books
          end
        end

        zones = TimeZone.where(:supply_condition_id => effect_conditions.id, :status => 't').order('sequence ASC')
        zones_books = []
        if !zones.blank?
          zones.each_with_index do |z, j|
            has_books = false
            books = []

            i = 0
            while i < day_books.length
              if zones.count != (j + 1) && (zones[j + 1].present? && z.range_end == zones[j + 1].range_begin)
                if z.range_begin <= day_books[i].booking_time.strftime("%H:%M") && z.range_end > day_books[i].booking_time.strftime("%H:%M")
                  books.push(day_books[i])
                  has_books = true
                  day_books.to_a.delete(day_books[i])  # delete boj only from array
                  i = i - 1
                end
              else
                if z.range_begin <= day_books[i].booking_time.strftime("%H:%M") && z.range_end >= day_books[i].booking_time.strftime("%H:%M")
                  books.push(day_books[i])
                  has_books = true
                  day_books.to_a.delete(day_books[i])  # delete boj only from array
                  i = i - 1
                end
              end
              i = i + 1
            end

            if has_books == true
              zone_booking = ZoneBooking.new
              zone_booking.name = z.name
              zone_booking.books = books
              zones_books.push(zone_booking)
            end
          end

          if !day_books.blank? && day_books.length > 0
            zone_booking = ZoneBooking.new
            zone_booking.name = '其他時段'
            zone_booking.books = day_books
            zones_books.push(zone_booking)
          end
        end

        if !zones_books.blank?
          length = zones_books.length
          length.times do |i|
            if length != (i + 1)
              zones_books[i].books = zones_books[i].books - zones_books[i + 1].books
            end
          end
        end

        return zones_books
      else
        zones_books = []
        return zones_books
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:get_day_books(restaurant_id, special_day)"
      zones_books = []
      return zones_books
    end
  end

  def self.query_books_by_date(restaurant_id, date_start, date_end)
    begin
      if date_start.blank? && date_end.blank?
        now_month = Time.now.month
        now_year = Time.now.year
        daysOfMon = Time.days_in_month(now_month, now_year)
        date_start = "#{now_year}-#{now_month}-1"
        date_end = "#{now_year}-#{now_month}-#{daysOfMon} 23:59"
      end

      date_start = Time.parse(date_start)
      date_end = Time.parse(date_end)

      date_start = Time.parse(date_start.strftime("%Y-%m-%d") + " 00:00")
      date_end = Time.parse(date_end.strftime("%Y-%m-%d") + " 23:59")
      bookings = Booking.where(:restaurant_id => restaurant_id).where('booking_time >= ?', date_start).where('booking_time <= ?', date_end).order('booking_time ASC')

      #bookings.each do |b|
      #  b.booking_time = b.booking_time.strftime("%Y-%m-%d %H:%M")
      #end

      return bookings
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:query_books_by_date(restaurant_id, date_start, date_end)"
      return nil
    end
  end

  def self.modify_booking_save(origin_booking, ti)
    begin
      Booking.transaction do
        booking = Booking.find(origin_booking[:id].to_i)

        if booking.status != '0'
          return {:error => true, :message => '目前的訂位狀態無法修改!'}
        end

        origin_booking_time = booking.booking_time
        origin_num_of_people = booking.num_of_people
        booking.name = origin_booking[:name]
        booking.phone = origin_booking[:phone]
        booking.email = origin_booking[:email]

        da = Time.parse(origin_booking[:booking_time].to_s).strftime("%Y-%m-%d")
        da = "#{da} #{ti}"
        booking.booking_time = Time.parse(da)

        booking_num = origin_booking[:num_of_people].to_i

        if booking_num <= 0
          return {:error => true, :message => '訂位人數不能小於0!'}
        end

        booking.num_of_people = booking_num
        booking.remark = origin_booking[:remark]
        booking.save

        #========== before
        origin_day_bookings = DayBooking.where(:restaurant_id => booking.restaurant_id, :day => Date.parse(origin_booking_time.to_s))
        if origin_day_bookings.blank?
          Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:modify_booking_save(origin_booking)"
          return {:error => true, :message => '阿! 發生錯誤了! 修改訂位失敗!'}
        end

        origin_day_begin = Time.parse(origin_booking_time.strftime("%Y-%m-%d") + " 00:00")
        origin_conditions = SupplyCondition.where(:restaurant_id => booking.restaurant_id, :status => 't').where('range_begin <= ?', origin_day_begin).where('range_end >= ?',origin_day_begin).order('sequence ASC')
        origin_day_booking = origin_day_bookings.first
        if origin_conditions.blank? || origin_conditions.first.is_vacation == 't'
          origin_day_booking.other = origin_day_booking.zone1 + origin_day_booking.zone2 + origin_day_booking.zone3 + origin_day_booking.zone4 + origin_day_booking.zone5 + origin_day_booking.zone6  + origin_day_booking.other
          origin_day_booking.other = origin_day_booking.other - origin_num_of_people
          origin_day_booking.save
        else
          origin_condition = origin_conditions.first
          is_in_zone = false

          if origin_condition.available_week.split(',').include?(origin_booking_time.wday.to_s)
            origin_zones = TimeZone.where(:supply_condition_id => origin_condition.id, :status => 't')
            origin_zones.each_with_index do |z, j|
              if origin_zones.count != (j + 1) && (origin_zones[j + 1].present? && z.range_end == origin_zones[j + 1].range_begin)
                if z.range_begin <= origin_booking_time.strftime("%H:%M") && z.range_end > origin_booking_time.strftime("%H:%M")
                  if z.sequence == 0
                    origin_day_booking.zone1 = origin_day_booking.zone1 - origin_num_of_people
                  elsif z.sequence == 1
                    origin_day_booking.zone2 = origin_day_booking.zone2 - origin_num_of_people
                  elsif z.sequence == 2
                    origin_day_booking.zone3 = origin_day_booking.zone3 - origin_num_of_people
                  elsif z.sequence == 3
                    origin_day_booking.zone4 = origin_day_booking.zone4 - origin_num_of_people
                  elsif z.sequence == 4
                    origin_day_booking.zone5 = origin_day_booking.zone5 - origin_num_of_people
                  elsif z.sequence == 5
                    origin_day_booking.zone6 = origin_day_booking.zone6 - origin_num_of_people
                  end
                  is_in_zone = true
                  break;
                end
              else
                if z.range_begin <= origin_booking_time.strftime("%H:%M") && z.range_end >= origin_booking_time.strftime("%H:%M")
                  if z.sequence == 0
                    origin_day_booking.zone1 = origin_day_booking.zone1 - origin_num_of_people
                  elsif z.sequence == 1
                    origin_day_booking.zone2 = origin_day_booking.zone2 - origin_num_of_people
                  elsif z.sequence == 2
                    origin_day_booking.zone3 = origin_day_booking.zone3 - origin_num_of_people
                  elsif z.sequence == 3
                    origin_day_booking.zone4 = origin_day_booking.zone4 - origin_num_of_people
                  elsif z.sequence == 4
                    origin_day_booking.zone5 = origin_day_booking.zone5 - origin_num_of_people
                  elsif z.sequence == 5
                    origin_day_booking.zone6 = origin_day_booking.zone6 - origin_num_of_people
                  end
                  is_in_zone = true
                  break;
                end
              end
            end
          end

          if is_in_zone == false
            origin_day_booking.other = origin_day_booking.other - origin_num_of_people
          end

          origin_day_booking.save
        end


        #========== after

        day_bookings = DayBooking.where(:restaurant_id => booking.restaurant_id, :day => Date.parse(booking.booking_time.to_s))
        if day_bookings.blank?
          day_booking = DayBooking.new
          day_booking.restaurant_id = booking.restaurant_id
          day_booking.day = Date.parse(booking.booking_time.to_s)
          day_booking.zone1 = 0
          day_booking.zone2 = 0
          day_booking.zone3 = 0
          day_booking.zone4 = 0
          day_booking.zone5 = 0
          day_booking.zone6 = 0
          day_booking.other = 0
        else
          day_booking = day_bookings.first
        end

        day_begin = Time.parse(booking.booking_time.strftime("%Y-%m-%d") + " 00:00")
        conditions = SupplyCondition.where(:restaurant_id => booking.restaurant_id, :status => 't').where('range_begin <= ?', day_begin).where('range_end >= ?',day_begin).order('sequence ASC')

        if conditions.blank? || conditions.first.is_vacation == 't'
          day_booking.other = day_booking.zone1 + day_booking.zone2 + day_booking.zone3 + day_booking.zone4 + day_booking.zone5 + day_booking.zone6 + day_booking.other
          day_booking.other = day_booking.other + booking.num_of_people
          day_booking.save
        else
          condition = conditions.first

          is_in_zone = false
          if condition.available_week.split(',').include?(booking.booking_time.wday.to_s)
            zones = TimeZone.where(:supply_condition_id => condition.id, :status => 't')
            zones.each_with_index do |z, j|
              if zones.count != (j + 1) && (zones[j + 1].present? && z.range_end == zones[j + 1].range_begin)
                if z.range_begin <= booking.booking_time.strftime("%H:%M") && z.range_end > booking.booking_time.strftime("%H:%M")
                  if z.sequence == 0
                    day_booking.zone1 = day_booking.zone1 + booking.num_of_people
                  elsif z.sequence == 1
                    day_booking.zone2 = day_booking.zone2 + booking.num_of_people
                  elsif z.sequence == 2
                    day_booking.zone3 = day_booking.zone3 + booking.num_of_people
                  elsif z.sequence == 3
                    day_booking.zone4 = day_booking.zone4 + booking.num_of_people
                  elsif z.sequence == 4
                    day_booking.zone5 = day_booking.zone5 + booking.num_of_people
                  elsif z.sequence == 5
                    day_booking.zone6 = day_booking.zone6 + booking.num_of_people
                  end
                  is_in_zone = true
                  break;
                end
              else
                if z.range_begin <= booking.booking_time.strftime("%H:%M") && z.range_end >= booking.booking_time.strftime("%H:%M")
                  if z.sequence == 0
                    day_booking.zone1 = day_booking.zone1 + booking.num_of_people
                  elsif z.sequence == 1
                    day_booking.zone2 = day_booking.zone2 + booking.num_of_people
                  elsif z.sequence == 2
                    day_booking.zone3 = day_booking.zone3 + booking.num_of_people
                  elsif z.sequence == 3
                    day_booking.zone4 = day_booking.zone4 + booking.num_of_people
                  elsif z.sequence == 4
                    day_booking.zone5 = day_booking.zone5 + booking.num_of_people
                  elsif z.sequence == 5
                    day_booking.zone6 = day_booking.zone6 + booking.num_of_people
                  end
                  is_in_zone = true
                  break;
                end
              end
            end
          end

          if is_in_zone == false
            day_booking.other = day_booking.other + booking.num_of_people
          end

          day_booking.save
        end

        booking.phone = nil
        booking.res_url = APP_CONFIG['domain'] + "#{booking.res_url}"
        booking.cancel_key = APP_CONFIG['domain_clear'] + "home/cancel_booking_by_email?cancel_key=" + "#{booking.cancel_key}"  + "&booking_key=" + "#{booking.id}"
        #MyMailer.modify_booking(booking.email ,booking).deliver
        MyMailer.delay_for(1.second).modify_booking(booking.id, APP_CONFIG['domain'], APP_CONFIG['domain_clear'])    # sidekiq
        return {:success => true, :data => '修改成功!'}
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:modify_booking_save(origin_booking)"
      return {:error => true, :message => '阿! 發生錯誤了! 修改失敗!'}
    end
  end

  def self.cancel_booking_email(cancel_booking)
    begin
      booker_phone = cancel_booking[:phone].strip
      booking_id = cancel_booking[:id]
      cancel_status = cancel_booking[:status]
      cancel_note = cancel_booking[:cancel_note]

      if booker_phone.blank?
        return {:error => true, :message => '手機號碼要填喔~!'}
      end

      booking = Booking.find(booking_id.to_i)

      if booking.phone != booker_phone
        return {:error => true, :message => '手機號碼錯誤~!' }
      end

      return cancel_booking(booking_id, cancel_status, cancel_note, true)
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:cancel_booking_email(cancel_booking)"
      return {:error => true, :message => '阿! 發生錯誤了! 取消訂位失敗!'}
    end
  end

  def self.cancel_booking(booking_id, status, cancel_note, notice_restaurant)
    begin
      Booking.transaction do
        booking = Booking.find(booking_id.to_i)

        if booking.status.blank?
          return {:error => true, :message => '阿! 發生錯誤了! 取消訂位失敗!'}
        end

        if booking.status == '1'
          return {:error => true, :message => '已經到店用餐，無法取消訂位!'}
        elsif booking.status != '0'
          return {:error => true, :message => '該訂位已經取消，無法再取消訂位，目前不開放，變更取消原因!'}
        end

        booking.status = status
        if booking.status == '7'
          booking.cancel_note = cancel_note
        end
        booking.save
        b_num_of_people =  booking.num_of_people
        day_bookings = DayBooking.where(:restaurant_id => booking.restaurant_id, :day => Date.parse(booking.booking_time.to_s))
        if day_bookings.blank?
          Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:cancel_booking(origin_booking)"
          return {:error => true, :message => '阿! 發生錯誤了! 取消訂位失敗!'}
        end
        day_booking = day_bookings.first
        day_begin = Time.parse(booking.booking_time.strftime("%Y-%m-%d") + " 00:00")
        conditions = SupplyCondition.where(:restaurant_id => booking.restaurant_id, :status => 't').where('range_begin <= ?', day_begin).where('range_end >= ?',day_begin).order('is_vacation IS NULL, is_special IS NULL, sequence ASC')

        if conditions.blank?
          day_booking.other = day_booking.zone1 + day_booking.zone2 + day_booking.zone3 + day_booking.zone4 + day_booking.zone5 + day_booking.zone6  + day_booking.other
          day_booking.save
        else
          condition = conditions.first
          if condition.is_vacation.blank?
            zones = TimeZone.where(:supply_condition_id => condition.id, :status => 't')
            zones.each_with_index do |z, j|
              if zones.count != (j + 1) && (zones[j + 1].present? && z.range_end == zones[j + 1].range_begin)

                if z.range_begin <= booking.booking_time.strftime("%H:%M") && z.range_end > booking.booking_time.strftime("%H:%M")
                  if z.sequence == 0
                    day_booking.zone1 = day_booking.zone1 - booking.num_of_people
                  elsif z.sequence == 1
                    day_booking.zone2 = day_booking.zone2 - booking.num_of_people
                  elsif z.sequence == 2
                    day_booking.zone3 = day_booking.zone3 - booking.num_of_people
                  elsif z.sequence == 3
                    day_booking.zone4 = day_booking.zone4 - booking.num_of_people
                  elsif z.sequence == 4
                    day_booking.zone5 = day_booking.zone5 - booking.num_of_people
                  elsif z.sequence == 5
                    day_booking.zone6 = day_booking.zone6 - booking.num_of_people
                  end
                  booking.num_of_people = 0
                  break;
                end
              else
                if z.range_begin <= booking.booking_time.strftime("%H:%M") && z.range_end >= booking.booking_time.strftime("%H:%M")
                  if z.sequence == 0
                    day_booking.zone1 = day_booking.zone1 - booking.num_of_people
                  elsif z.sequence == 1
                    day_booking.zone2 = day_booking.zone2 - booking.num_of_people
                  elsif z.sequence == 2
                    day_booking.zone3 = day_booking.zone3 - booking.num_of_people
                  elsif z.sequence == 3
                    day_booking.zone4 = day_booking.zone4 - booking.num_of_people
                  elsif z.sequence == 4
                    day_booking.zone5 = day_booking.zone5 - booking.num_of_people
                  elsif z.sequence == 5
                    day_booking.zone6 = day_booking.zone6 - booking.num_of_people
                  end
                  booking.num_of_people = 0
                  break;
                end
              end

            end
          end

          if booking.num_of_people != 0 && day_booking.other > 0
            day_booking.other = day_booking.other - booking.num_of_people;
          end
          day_booking.save
        end

        bphone = booking.phone
        if booking.email.present?
          booking.phone = nil
          booking.num_of_people = b_num_of_people
          booking.res_url = APP_CONFIG['domain'] + "#{booking.res_url}"
          #MyMailer.cancel_booking(booking.email ,booking).deliver
          MyMailer.delay_for(1.second).cancel_booking(booking.id, APP_CONFIG['domain'])    # sidekiq
        end

        if notice_restaurant && booking.restaurant_id.present?
          restaurant = Restaurant.find(booking.restaurant_id)
          if restaurant.present?
            semail = restaurant.supply_email.split(',')
            if semail.count == 1
              semail = semail[0].split(';')
            end

            if semail.present?
              effect_email = []
              semail.each do |e|
                if !e.blank? && !(e =~ /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/).blank?
                  effect_email.push(e)
                end
              end

              if effect_email.present?
                booking.phone = bphone
                #MyMailer.notice_cancel_booking(effect_email, restaurant, booking).deliver
                MyMailer.delay_for(1.second).notice_cancel_booking(effect_email, restaurant.id, booking.id, APP_CONFIG['domain'])   # sidekiq
              end
            end
          end
        end

        if booking.status == '2'
          status_string = '取消訂位(同伴無法配合)'
        elsif booking.status == '3'
          status_string = '取消訂位(餐廳當天座位不夠)'
        elsif booking.status == '4'
          status_string = '取消訂位(選擇了其他餐廳)'
        elsif booking.status == '5'
          status_string = '取消訂位(餐廳臨時公休)'
        elsif booking.status == '6'
          status_string = '取消訂位(聚餐延期)'
        elsif booking.status == '7'
          status_string = '取消訂位(原因:' + cancel_note  + ')'
        end

        return {:success => true, :data => '已取消訂位!', :status_string => status_string}
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:cancel_booking(origin_booking)"
      return {:error => true, :message => '阿! 發生錯誤了! 取消訂位失敗!'}
    end
  end

  def self.calculate_day_booking_all(restaurant_id)
    # don't catch this method error , transaction issue
    day_bookings = DayBooking.where(:restaurant_id => restaurant_id).order('day ASC')
    if day_bookings.blank?
      return
    end
    conditions = SupplyCondition.where(:restaurant_id => restaurant_id, :status => 't').order('sequence ASC')
    bookings = Booking.where(:restaurant_id => restaurant_id).where('status=? OR status=?', '0', '1').group('booking_time').sum(:num_of_people)

    calculate_day_booking(day_bookings, conditions, bookings)
  end

  def self.calculate_day_booking_part(restaurant_id, condition_id)
    # don't catch this method error , transaction issue
    origin_condition = SupplyCondition.find(condition_id)
    day_bookings = DayBooking.where(:restaurant_id => restaurant_id).where('day >= ?', origin_condition.range_begin).where('day <= ?', origin_condition.range_end).order('day ASC')
    if day_bookings.blank?
      return
    end
    conditions = SupplyCondition.where(:restaurant_id => restaurant_id, :status => 't').where('range_begin <= ?', origin_condition.range_begin).where('range_end >= ?', origin_condition.range_end).order('sequence ASC')
    bookings = Booking.where(:restaurant_id => restaurant_id).where('status=? OR status=?', '0', '1').where('booking_time >= ?', origin_condition.range_begin).where('booking_time <= ?', origin_condition.range_end).group('booking_time').sum(:num_of_people)#.order('booking_time ASC')

    calculate_day_booking(day_bookings, conditions, bookings)
  end

  def self.calculate_day_booking_special(restaurant_id, condition_id)
    # don't catch this method error , transaction issue
    origin_condition = SupplyCondition.find(condition_id)
    day_bookings = DayBooking.where(:restaurant_id => restaurant_id).where('day >= ?', origin_condition.range_begin).where('day <= ?', origin_condition.range_end).order('day ASC')
    if day_bookings.blank?
      return
    end

    bookings = Booking.where(:restaurant_id => restaurant_id).where('status=? OR status=?', '0', '1').where('booking_time >= ?', origin_condition.range_begin).where('booking_time <= ?', origin_condition.range_end).group('booking_time').sum(:num_of_people)#.order('booking_time ASC')

    day_booking_mix = []
    day_bookings.each do |db|
      day_booking_group = []
      db.zone1 = 0
      db.zone2 = 0
      db.zone3 = 0
      db.zone4 = 0
      db.zone5 = 0
      db.zone6 = 0
      db.other = 0
      day_booking_group.push(db)
      db_begin = Time.parse(db.day.strftime("%Y-%m-%d") + " 00:00")
      db_end = Time.parse(db.day.strftime("%Y-%m-%d") + " 23:59")

      bookings_of_group = []
      bookings.each do |b|
        if db_begin <= b[0] && db_end >= b[0]
          b.push(b[0].strftime("%H:%M"))                # [time,sum(num_of_people),'11:00']
          bookings_of_group.push(b)
        end
      end

      day_booking_group.push(bookings_of_group)           # [day_bookings, bookings_of_group]
      day_booking_mix.push(day_booking_group)
    end

    if origin_condition.is_vacation == 't'
      #把所有bookings 直接以other 丟到day_booking
      day_booking_mix.each do |mix|
        mix[1].each do |books|
          mix[0].other = mix[0].other + books[1]
        end

        mix[0].save
      end
    else
      #zones = TimeZone.where(:supply_condition_id => c.id, :status => 't').order('sequence ASC')
      #zones = TimeZone.where(:supply_condition_id => origin_condition.id).order('sequence ASC')
      zones = TimeZone.where(:supply_condition_id => origin_condition.id, :status => 't').order('sequence ASC')

      day_booking_mix.each do |mix|
        if origin_condition.range_begin <= mix[0].day && origin_condition.range_end >= mix[0].day

          zones.each_with_index do |z, j|
            i = 0
            while i < mix[1].length
              books = mix[1][i]

              if zones.count != (j + 1) && (zones[j + 1].present? && z.range_end == zones[j + 1].range_begin)
                if z.range_begin <= books[2] && z.range_end > books[2]
                  if z.sequence == 0
                    mix[0].zone1 = mix[0].zone1 + books[1]
                  elsif z.sequence == 1
                    mix[0].zone2 = mix[0].zone2 + books[1]
                  elsif z.sequence == 2
                    mix[0].zone3 = mix[0].zone3 + books[1]
                  elsif z.sequence == 3
                    mix[0].zone4 = mix[0].zone4 + books[1]
                  elsif z.sequence == 4
                    mix[0].zone5 = mix[0].zone5 + books[1]
                  elsif z.sequence == 5
                    mix[0].zone6 = mix[0].zone6 + books[1]
                  end
                  mix[1].to_a.delete(books)
                  i = i - 1
                end
              else
                if z.range_begin <= books[2] && z.range_end >= books[2]
                  if z.sequence == 0
                    mix[0].zone1 = mix[0].zone1 + books[1]
                  elsif z.sequence == 1
                    mix[0].zone2 = mix[0].zone2 + books[1]
                  elsif z.sequence == 2
                    mix[0].zone3 = mix[0].zone3 + books[1]
                  elsif z.sequence == 3
                    mix[0].zone4 = mix[0].zone4 + books[1]
                  elsif z.sequence == 4
                    mix[0].zone5 = mix[0].zone5 + books[1]
                  elsif z.sequence == 5
                    mix[0].zone6 = mix[0].zone6 + books[1]
                  end
                  mix[1].to_a.delete(books)
                  i = i - 1
                end
              end

              i = i + 1
            end

            #mix[1].each do |books|
            #  if z.range_begin <= books[2] && z.range_end > books[2]
            #    if z.status == 'f'
            #      mix[0].other = mix[0].other + books[1]
            #      mix[1].to_a.delete(books)
            #    else
            #      if z.sequence == 0
            #        mix[0].zone1 = mix[0].zone1 + books[1]
            #        mix[1].to_a.delete(books)
            #      elsif z.sequence == 1
            #        mix[0].zone2 = mix[0].zone2 + books[1]
            #        mix[1].to_a.delete(books)
            #      elsif z.sequence == 2
            #        mix[0].zone3 = mix[0].zone3 + books[1]
            #        mix[1].to_a.delete(books)
            #      elsif z.sequence == 3
            #        mix[0].zone4 = mix[0].zone4 + books[1]
            #        mix[1].to_a.delete(books)
            #      elsif z.sequence == 4
            #        mix[0].zone5 = mix[0].zone5 + books[1]
            #        mix[1].to_a.delete(books)
            #      elsif z.sequence == 5
            #        mix[0].zone6 = mix[0].zone6 + books[1]
            #        mix[1].to_a.delete(books)
            #      end
            #    end
            #  end
            #end
          end

        end
        mix[0].save
      end

      day_booking_mix.each do |mix|
        not_sum_count = 0

        mix[1].each do |books|
          not_sum_count = not_sum_count + books[1]
        end

        if not_sum_count > 0
          mix[0].other = not_sum_count
          mix[0].save
        end
      end

    end
  end

  def self.calculate_day_booking(day_bookings, conditions, bookings)
    # don't catch this method error , transaction issue

    day_booking_mix = []
    day_bookings.each do |db|
      day_booking_group = []
      db.zone1 = 0
      db.zone2 = 0
      db.zone3 = 0
      db.zone4 = 0
      db.zone5 = 0
      db.zone6 = 0
      db.other = 0
      day_booking_group.push(db)
      db_begin = Time.parse(db.day.strftime("%Y-%m-%d") + " 00:00")
      db_end = Time.parse(db.day.strftime("%Y-%m-%d") + " 23:59")

      bookings_of_group = []
      bookings.each do |b|
        if db_begin <= b[0] && db_end >= b[0]
          b.push(b[0].strftime("%H:%M"))                # [time,sum(num_of_people),'11:00']
          bookings_of_group.push(b)
        end
      end

      day_booking_group.push(bookings_of_group)           # [day_bookings, bookings_of_group]
      day_booking_mix.push(day_booking_group)
    end

    if conditions.blank?
      #把所有bookings 直接以other 丟到day_booking
      day_booking_mix.each do |mix|
        mix[1].each do |books|
          mix[0].other = mix[0].other + books[1]
        end

        mix[0].save
      end
    end

    conditions.each do |c|
      zones = TimeZone.where(:supply_condition_id => c.id, :status => 't').order('sequence ASC')

      day_booking_mix.each do |mix|
        if c.range_begin <= mix[0].day && c.range_end >= mix[0].day

          if c.is_vacation == 't'
            mix[1].each do |books|
              mix[0].other = mix[0].other + books[1]
            end
          else
            zones.each_with_index do |z, j|

              i = 0
              while i < mix[1].length
                books = mix[1][i]
                if zones.count != (j + 1) && (zones[j + 1].present? && z.range_end == zones[j + 1].range_begin)
                  if z.range_begin <= books[2] && z.range_end > books[2]
                    if z.sequence == 0
                      mix[0].zone1 = mix[0].zone1 + books[1]
                    elsif z.sequence == 1
                      mix[0].zone2 = mix[0].zone2 + books[1]
                    elsif z.sequence == 2
                      mix[0].zone3 = mix[0].zone3 + books[1]
                    elsif z.sequence == 3
                      mix[0].zone4 = mix[0].zone4 + books[1]
                    elsif z.sequence == 4
                      mix[0].zone5 = mix[0].zone5 + books[1]
                    elsif z.sequence == 5
                      mix[0].zone6 = mix[0].zone6 + books[1]
                    end
                    mix[1].to_a.delete(books)
                    i = i - 1
                  end
                else
                  if z.range_begin <= books[2] && z.range_end >= books[2]
                    if z.sequence == 0
                      mix[0].zone1 = mix[0].zone1 + books[1]
                    elsif z.sequence == 1
                      mix[0].zone2 = mix[0].zone2 + books[1]
                    elsif z.sequence == 2
                      mix[0].zone3 = mix[0].zone3 + books[1]
                    elsif z.sequence == 3
                      mix[0].zone4 = mix[0].zone4 + books[1]
                    elsif z.sequence == 4
                      mix[0].zone5 = mix[0].zone5 + books[1]
                    elsif z.sequence == 5
                      mix[0].zone6 = mix[0].zone6 + books[1]
                    end
                    mix[1].to_a.delete(books)
                    i = i - 1
                  end
                end
                i = i + 1
              end
            end
          end
        end
        mix[0].save
      end
    end

    day_booking_mix.each do |mix|
      not_sum_count = 0

      mix[1].each do |books|
        not_sum_count = not_sum_count + books[1]
      end

      if not_sum_count > 0
        mix[0].other = not_sum_count
        mix[0].save
      end
    end

  end



end