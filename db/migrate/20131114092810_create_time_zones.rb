class CreateTimeZones < ActiveRecord::Migration
  def change
    create_table :time_zones do |t|
      t.integer :supply_condition_id
      t.integer :sequence
      t.string :name                , :limit => 20
      t.string :range_begin         , :limit => 5
      t.string :range_end           , :limit => 5
      t.integer :each_allow
      t.integer :fifteen_allow
      t.integer :total_allow
      t.string :status              , :limit => 1

      t.timestamps
    end

    add_index :time_zones, :supply_condition_id
    add_index :time_zones, :status
  end
end
