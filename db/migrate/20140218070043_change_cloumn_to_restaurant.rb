class ChangeCloumnToRestaurant < ActiveRecord::Migration
  def change
    change_column :restaurants, :url1, :string, :limit => 500
    change_column :restaurants, :url2, :string, :limit => 500
    change_column :restaurants, :url3, :string, :limit => 500
  end
end
