class Booking < ActiveRecord::Base
  OUT_OF_LENGTH = '資料長度超過限制'
  NOT_EMPTY = '不能空白'
  MUST_BE_INTEGER = '必須是整數'
  #validates :user_id, :presence => { :message => "使用者編號，" + NOT_EMPTY } ,
  #                    :length => { :maximum => 11, :message => "使用者編號，" + OUT_OF_LENGTH } ,
  #                    :numericality => { :only_integer => true, :message => "使用者編號，" + MUST_BE_INTEGER }
  validates :restaurant_id, :presence => { :message => "餐廳編號，" + NOT_EMPTY } ,
                            :length => { :maximum => 11, :message => "餐廳編號，" + OUT_OF_LENGTH } ,
                            :numericality => { :only_integer => true, :message => "餐廳編號，" + MUST_BE_INTEGER }
  validates :res_url, :presence => { :message => "餐廳訂位網址標記，" + NOT_EMPTY } ,
                      :length => { :maximum => 30, :message => "餐廳訂位網址標記，" + OUT_OF_LENGTH }
  validates :restaurant_name, :presence => { :message => "餐廳名稱，" + NOT_EMPTY } ,
                              :length => { :maximum => 50, :message => "餐廳名稱，" + OUT_OF_LENGTH }
  validates :restaurant_address, :presence => { :message => "餐廳地址，" + NOT_EMPTY } ,
                                 :length => { :maximum => 180, :message => "餐廳地址，" + OUT_OF_LENGTH }
  validates :name, :presence => { :message => "訂位者姓名，" + NOT_EMPTY } ,
                   :length => { :maximum => 20, :message => "訂位者姓名，" + OUT_OF_LENGTH }
  validates :phone, :presence => { :message => "訂位者電話，" + NOT_EMPTY } ,
                    :length => { :maximum => 30, :message => "訂位者電話，" + OUT_OF_LENGTH }
  validates :email, :length => { :maximum => 60, :message => "E-mail，" + OUT_OF_LENGTH }
  validates :remark, :length => { :maximum => 200, :message => "備註，" + OUT_OF_LENGTH }
  validates :num_of_people, :presence => { :message => "訂位人數，" + NOT_EMPTY } ,
                            :length => { :maximum => 11, :message => "訂位人數，" + OUT_OF_LENGTH } ,
                            :numericality => { :only_integer => true, :message => "訂位人數，" + MUST_BE_INTEGER }
  validates :participants, :length => { :maximum => 1000, :message => "用餐與會者 E-mail，" + OUT_OF_LENGTH }
  validates :status, :presence => { :message => "狀態，" + NOT_EMPTY } ,
                     :length => { :maximum => 1, :message => "狀態，" + OUT_OF_LENGTH }
  validates :cancel_note, :length => { :maximum => 100, :message => "取消訂位其他原因，" + OUT_OF_LENGTH }
  validates :feedback, :length => { :maximum => 200, :message => "用餐心得，" + OUT_OF_LENGTH }
  validates :restaurant_pic, :length => { :maximum => 255, :message => "餐廳圖片名稱，" + OUT_OF_LENGTH }
end
