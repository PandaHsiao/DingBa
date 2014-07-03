class SupplyCondition < ActiveRecord::Base
  OUT_OF_LENGTH = '資料長度超過限制'
  NOT_EMPTY = '不能空白'
  MUST_BE_INTEGER = '必須是整數'
  validates :restaurant_id, :presence => { :message => "餐廳編號，" + NOT_EMPTY } ,
                            :length => { :maximum => 11, :message => "餐廳編號，" + OUT_OF_LENGTH } ,
                            :numericality => { :only_integer => true, :message => "餐廳編號，" + MUST_BE_INTEGER }
  validates :name, :presence => { :message => "餐廳名稱，" + NOT_EMPTY } ,
                   :length => { :maximum => 50, :message => "餐廳名稱，" + OUT_OF_LENGTH }
  validates :available_week, :length => { :maximum => 15, :message => "開放星期，" + OUT_OF_LENGTH }
  validates :status, :presence => { :message => "狀態，" + NOT_EMPTY } ,
                     :length => { :maximum => 1, :message => "狀態，" + OUT_OF_LENGTH }
  validates :is_special, :length => { :maximum => 1, :message => "特別狀態，" + OUT_OF_LENGTH }
  validates :is_vacation, :length => { :maximum => 1, :message => "休假狀態，" + OUT_OF_LENGTH }
end
