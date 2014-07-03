class BookerManage

  def self.save_feedback(booking_id, feedback)
    begin
      booking = Booking.find(booking_id.to_i)
      booking.feedback = feedback
      booking.save!

      return {:success => true, :data => '儲存成功!'}
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/booker_manage.rb  ,Method:save_feedback(booking_id, feedback)"
      return {:error => true, :message => '阿! 發生錯誤了! 儲存失敗!'}
    end
  end

  def self.get_books(booker_id)
    begin
      books = Booking.where(:user_id => booker_id,:status => '0').where('booking_time <= ?', Time.now).order('booking_time DESC')
      books.update_all(:status => '1')

      updated_books = Booking.where(:user_id => booker_id).order('booking_time DESC')
      return updated_books
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/booker_manage.rb  ,Method:get_books"
    end
  end

end