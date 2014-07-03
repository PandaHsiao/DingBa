class AddSexBirthToUser < ActiveRecord::Migration
  def change
    add_column :users, :sex, :string
    add_column :users, :birthday, :datetime
  end
end
