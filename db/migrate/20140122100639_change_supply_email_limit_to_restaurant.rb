class ChangeSupplyEmailLimitToRestaurant < ActiveRecord::Migration
  def change
    change_column :restaurants, :supply_email , :string, :limit => 1000
  end
end
