class Counters < ActiveRecord::Migration
  def self.up
    create_table :counters do |t|
      t.integer :counter
      t.integer :counter_last_day
      t.integer :counter_last_2_days
      t.integer :counter_last_monday
      t.integer :counter_last_tuesday
      t.integer :counter_last_wednesday
      t.string :counter_data, :limit => 2048
    end
  end

  def self.down
    drop_table :counters
  end
end
