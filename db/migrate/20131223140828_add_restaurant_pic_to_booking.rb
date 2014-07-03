class AddRestaurantPicToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :restaurant_pic, :string
  end
end
