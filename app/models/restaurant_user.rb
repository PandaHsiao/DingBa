class RestaurantUser < ActiveRecord::Base
  OUT_OF_LENGTH = '資料長度超過限制'
  NOT_EMPTY = '不能空白'
  MUST_BE_INTEGER = '必須是整數'
  validates :restaurant_id, :presence => { :message => "餐廳編號，" + NOT_EMPTY } ,
                            :length => { :maximum => 11, :message => "餐廳編號，" + OUT_OF_LENGTH } ,
                            :numericality => { :only_integer => true, :message => "餐廳編號，" + MUST_BE_INTEGER }
  validates :restaurant_id, :presence => { :message => "使用者編號，" + NOT_EMPTY } ,
                            :length => { :maximum => 11, :message => "使用者編號，" + OUT_OF_LENGTH } ,
                            :numericality => { :only_integer => true, :message => "使用者編號，" + MUST_BE_INTEGER }
  validates :permission, :presence => { :message => "權限標記，" + NOT_EMPTY } ,
                         :length => { :maximum => 1, :message => "權限標記，" + OUT_OF_LENGTH }
end
