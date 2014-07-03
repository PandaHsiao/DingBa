class AddAllowPromotToUser < ActiveRecord::Migration
  def change
    add_column :users, :allow_promot, :string   , :limit => 1
  end
end
