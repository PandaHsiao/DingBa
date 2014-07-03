class CreateRestaurantUsers < ActiveRecord::Migration
  def change
    create_table :restaurant_users do |t|
      t.integer :restaurant_id
      t.integer :user_id
      t.string  :permission, :limit => 1

      t.timestamps
    end

    add_index :restaurant_users, :restaurant_id
    add_index :restaurant_users, :user_id
  end
end
