class CreateInviteCodes < ActiveRecord::Migration
  def change
    create_table :invite_codes do |t|
      t.string :code             , :limit => 8
      t.integer :user_id
      t.string :remark           , :limit => 50

      t.timestamps
    end
  end
end
