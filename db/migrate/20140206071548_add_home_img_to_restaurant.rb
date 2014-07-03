class AddHomeImgToRestaurant < ActiveRecord::Migration
  def change
    add_column :restaurants, :home_img, :string    , :limit => 50
    add_column :restaurants, :home_des, :string    , :limit => 40
  end
end
