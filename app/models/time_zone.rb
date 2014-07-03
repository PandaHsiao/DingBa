class TimeZone < ActiveRecord::Base
  OUT_OF_LENGTH = '資料長度超過限制'
  NOT_EMPTY = '不能空白'
  MUST_BE_INTEGER = '必須是整數'
  validates :supply_condition_id, :presence => { :message => "條件編號，" + NOT_EMPTY } ,
                                  :length => { :maximum => 11, :message => "條件編號，" + OUT_OF_LENGTH } ,
                                  :numericality => { :only_integer => true, :message => "條件編號，" + MUST_BE_INTEGER }
  validates :sequence, :presence => { :message => "序號，" + NOT_EMPTY } ,
                       :length => { :maximum => 11, :message => "序號，" + OUT_OF_LENGTH } ,
                       :numericality => { :only_integer => true, :message => "序號，" + MUST_BE_INTEGER }
  validates :range_begin, :presence => { :message => "起始時間，" + NOT_EMPTY } ,
                          :length => { :maximum => 5, :message => "起始時間，" + OUT_OF_LENGTH }
  validates :range_end, :presence => { :message => "結束時間，" + NOT_EMPTY } ,
                        :length => { :maximum => 5, :message => "結束時間，" + OUT_OF_LENGTH }
  validates :each_allow, :length => { :maximum => 11, :message => "每次接受人數，" + OUT_OF_LENGTH } #,
                         #:numericality => { :only_integer => true, :message => "每次接受人數，" + MUST_BE_INTEGER }
  validates :fifteen_allow, :length => { :maximum => 11, :message => "每15分鐘接受人數，" + OUT_OF_LENGTH } #,
                            #:numericality => { :only_integer => true, :message => "每次接受人數，" + MUST_BE_INTEGER }
  validates :total_allow, :length => { :maximum => 11, :message => "總接受人數，" + OUT_OF_LENGTH } #,
                          #:numericality => { :only_integer => true, :message => "總人數，" + MUST_BE_INTEGER }
  validates :status, :presence => { :message => "狀態，" + NOT_EMPTY } ,
                     :length => { :maximum => 1, :message => "狀態，" + OUT_OF_LENGTH }
end
