class CountersWithoutStartingValue < ActiveRecord::Migration
  def self.up
    create_table :counters do |t|
      t.integer :counter
      t.datetime :counter_computed_at
      t.integer :counter_last_day
      t.integer :counter_last_2_days
      t.integer :counter_last_week
      t.integer :counter_last_2_weeks
    end
  end

  def self.down
    drop_table :counters
  end
end
