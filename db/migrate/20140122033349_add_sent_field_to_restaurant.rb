class AddSentFieldToRestaurant < ActiveRecord::Migration
  def change
    add_column :restaurants, :sent_type, :string     , :limit => 1
    add_column :restaurants, :sent_date, :string     , :limit => 5
  end
end
