class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.integer :user_id
      t.integer :restaurant_id
      t.datetime :booking_time
      t.string :res_url           , :limit => 30
      t.string :restaurant_name   , :limit => 50
      t.string :restaurant_address, :limit => 180
      t.string :name              , :limit => 20
      t.string :phone             , :limit => 30
      t.string :email             , :limit => 60
      t.string :remark            , :limit => 200
      t.integer :num_of_people
      t.string :participants      , :limit => 1000
      t.string :status            , :limit => 1
      t.string :cancel_note       , :limit => 100
      t.string :feedback          , :limit => 200

      t.timestamps
    end

    add_index :bookings, :user_id
    add_index :bookings, :booking_time
    add_index :bookings, :status
  end
end