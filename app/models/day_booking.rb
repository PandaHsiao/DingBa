class DayBooking < ActiveRecord::Base
  OUT_OF_LENGTH = '資料長度超過限制'
  NOT_EMPTY = '不能空白'
  MUST_BE_INTEGER = '必須是整數'
  validates :restaurant_id, :presence => { :message => "餐廳編號，" + NOT_EMPTY } ,
                            :length => { :maximum => 11, :message => "餐廳編號，" + OUT_OF_LENGTH } ,
                            :numericality => { :only_integer => true, :message => "餐廳編號，" + MUST_BE_INTEGER }
  validates :zone1, :length => { :maximum => 11, :message => "區段1數量，" + OUT_OF_LENGTH } ,
                    :numericality => { :only_integer => true, :message => "區段1數量，" + MUST_BE_INTEGER }
  validates :zone2, :length => { :maximum => 11, :message => "區段2數量，" + OUT_OF_LENGTH } ,
                    :numericality => { :only_integer => true, :message => "區段2數量，" + MUST_BE_INTEGER }
  validates :zone3, :length => { :maximum => 11, :message => "區段3數量，" + OUT_OF_LENGTH } ,
                    :numericality => { :only_integer => true, :message => "區段3數量，" + MUST_BE_INTEGER }
  validates :zone4, :length => { :maximum => 11, :message => "區段4數量，" + OUT_OF_LENGTH } ,
                    :numericality => { :only_integer => true, :message => "區段4數量，" + MUST_BE_INTEGER }
  validates :zone5, :length => { :maximum => 11, :message => "區段5數量，" + OUT_OF_LENGTH } ,
                    :numericality => { :only_integer => true, :message => "區段5數量，" + MUST_BE_INTEGER }
  validates :zone6, :length => { :maximum => 11, :message => "區段6數量，" + OUT_OF_LENGTH } ,
                    :numericality => { :only_integer => true, :message => "區段6數量，" + MUST_BE_INTEGER }
  validates :other, :length => { :maximum => 11, :message => "其他區段數量，" + OUT_OF_LENGTH } ,
                    :numericality => { :only_integer => true, :message => "其他區段數量，" + MUST_BE_INTEGER }
end
