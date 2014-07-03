class AddTagToRestaurant < ActiveRecord::Migration
  def change
    add_column :restaurants, :tag, :string

    add_index :restaurants, :tag
  end
end
