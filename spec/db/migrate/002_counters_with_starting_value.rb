class CountersWithStartingValue < ActiveRecord::Migration
  def self.up
    drop_table :counters
    create_table :counters do |t|
      t.integer :counter
      t.integer :counter_starting_value
      t.datetime :counter_computed_at
      t.integer :counter_last_day
      t.integer :counter_last_2_days
      t.integer :counter_last_week
      t.integer :counter_last_2_weeks
    end
  end

  def self.down
  end
end
