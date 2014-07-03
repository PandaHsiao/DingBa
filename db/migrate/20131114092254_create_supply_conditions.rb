class CreateSupplyConditions < ActiveRecord::Migration
  def change
    create_table :supply_conditions do |t|
      t.integer :restaurant_id
      t.string :name                    , :limit => 50
      t.datetime :range_begin
      t.datetime :range_end
      t.string :available_week          , :limit => 15
      t.integer :sequence
      t.string :status                  , :limit => 1
      t.string :is_special              , :limit => 1
      t.string :is_vacation             , :limit => 1

      t.timestamps
    end

    add_index :supply_conditions, :restaurant_id
    add_index :supply_conditions, :range_begin
    add_index :supply_conditions, :range_end
    add_index :supply_conditions, :status
  end
end
