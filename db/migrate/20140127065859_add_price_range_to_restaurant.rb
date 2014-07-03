class AddPriceRangeToRestaurant < ActiveRecord::Migration
  def change
    add_column :restaurants, :price_from, :string   , :limit => 7
    add_column :restaurants, :price_to, :string    , :limit => 7
  end
end
