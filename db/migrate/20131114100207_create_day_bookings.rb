class CreateDayBookings < ActiveRecord::Migration
  def change
    create_table :day_bookings do |t|
      t.integer :restaurant_id
      t.datetime :day
      t.integer :zone1
      t.integer :zone2
      t.integer :zone3
      t.integer :zone4
      t.integer :zone5
      t.integer :zone6
      t.integer :other

      t.timestamps
    end

    add_index :day_bookings, :restaurant_id
    add_index :day_bookings, :day
  end
end
