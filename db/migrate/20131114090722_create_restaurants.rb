class CreateRestaurants < ActiveRecord::Migration
  def change
    create_table :restaurants do |t|
      t.string :res_url         , :limit => 30
      t.string :name            , :limit => 50
      t.string :phone           , :limit => 30
      t.string :city            , :limit => 15
      t.string :area            , :limit => 15
      t.string :address         , :limit => 150
      t.string :res_type        , :limit => 2
      t.string :feature         , :limit => 400
      t.string :business_hours  , :limit => 255
      t.string :pay_type        , :limit => 10
      t.string :supply_person   , :limit => 20
      t.string :supply_email    , :limit => 60
      t.string :url1            , :limit => 60
      t.string :url2            , :limit => 60
      t.string :url3            , :limit => 60
      t.string :info_url1       , :limit => 50
      t.string :info_url2       , :limit => 50
      t.string :info_url3       , :limit => 50
      t.string :front_cover     , :limit => 1
      t.string :pic_name1       , :limit => 50
      t.string :pic_name2       , :limit => 50
      t.string :pic_name3       , :limit => 50
      t.string :pic_name4       , :limit => 50
      t.string :pic_name5       , :limit => 50
      t.integer :available_hour
      t.string :available_date  , :limit => 5
      t.string :available_type  , :limit => 1

      t.timestamps
    end

    add_index :restaurants, :res_url,                :unique => true
    add_index :restaurants, :name
    add_index :restaurants, :city
    add_index :restaurants, :area
    add_index :restaurants, :res_type
    add_index :restaurants, :pay_type
    add_index :restaurants, :business_hours
  end
end
