class Restaurant < ActiveRecord::Base
  OUT_OF_LENGTH = '資料長度超過限制'
  NOT_EMPTY = '不能空白'
  MUST_BE_INTEGER = '必須是整數'

  validates :res_url, :presence => { :message => "餐廳訂位網址標記，"  + NOT_EMPTY } ,
                      :length => { :maximum => 30, :message => "餐廳訂位網址標記，" + OUT_OF_LENGTH }
  validates :name, :length => { :maximum => 50, :message => "餐廳名稱，" + OUT_OF_LENGTH }
  validates :phone, :length => { :maximum => 50, :message => "餐廳電話，" + OUT_OF_LENGTH }
  validates :city, :length => { :maximum => 15, :message => "縣市名稱，" + OUT_OF_LENGTH }
  validates :area, :length => { :maximum => 15, :message => "區域名稱，" + OUT_OF_LENGTH }
  validates :address, :length => { :maximum => 150, :message => "地址，" + OUT_OF_LENGTH }
  validates :res_type, :length => { :maximum => 2, :message => "餐廳類別，" + OUT_OF_LENGTH }
  validates :feature, :length => { :maximum => 400, :message => "餐廳特色，" + OUT_OF_LENGTH }
  validates :business_hours, :length => { :maximum => 255, :message => "營業時間，" + OUT_OF_LENGTH }
  validates :pay_type, :length => { :maximum => 10, :message => "付款方式，" + OUT_OF_LENGTH }
  validates :supply_person, :length => { :maximum => 20, :message => "供位聯絡人，" + OUT_OF_LENGTH }
  validates :supply_email, :format => { with: /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/, :message => "供位聯絡人 E-mail 格式錯誤喔!" },
                           :length => { :maximum => 1000, :message => "E-mail，" + OUT_OF_LENGTH }
  validates :url1, :length => { :maximum => 500, :message => "餐廳網址1，" + OUT_OF_LENGTH }
  validates :url2, :length => { :maximum => 500, :message => "餐廳網址2，" + OUT_OF_LENGTH }
  validates :url3, :length => { :maximum => 500, :message => "餐廳網址3，" + OUT_OF_LENGTH }
  validates :info_url1, :length => { :maximum => 50, :message => "網址名稱1，" + OUT_OF_LENGTH }
  validates :info_url2, :length => { :maximum => 50, :message => "網址名稱2，" + OUT_OF_LENGTH }
  validates :info_url3, :length => { :maximum => 50, :message => "網址名稱3，" + OUT_OF_LENGTH }
  validates :front_cover, :length => { :maximum => 1, :message => "封面設定，" + OUT_OF_LENGTH }
  validates :pic_name1, :length => { :maximum => 50, :message => "圖片名稱，" + OUT_OF_LENGTH }
  validates :pic_name2, :length => { :maximum => 50, :message => "圖片名稱，" + OUT_OF_LENGTH }
  validates :pic_name3, :length => { :maximum => 50, :message => "圖片名稱，" + OUT_OF_LENGTH }
  validates :pic_name4, :length => { :maximum => 50, :message => "圖片名稱，" + OUT_OF_LENGTH }
  validates :pic_name5, :length => { :maximum => 50, :message => "圖片名稱，" + OUT_OF_LENGTH }
  validates :available_hour, :length => { :maximum => 11, :message => "開放時間，" + OUT_OF_LENGTH } ,
                             :numericality => { :only_integer => true, :message => "開放時間，" + MUST_BE_INTEGER }
  validates :available_date, :length => { :maximum => 5, :message => "開放時間，" + OUT_OF_LENGTH }
  validates :available_type, :length => { :maximum => 1, :message => "開放訂位型態，" + OUT_OF_LENGTH }
end















