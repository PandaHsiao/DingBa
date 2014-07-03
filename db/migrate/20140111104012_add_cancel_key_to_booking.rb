class AddCancelKeyToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :cancel_key, :string
  end
end
