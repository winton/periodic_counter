class Counters < ActiveRecord::Migration
  def self.up
    create_table :counters do |t|
      t.integer :counter
      t.integer :counter_last_day
      t.integer :counter_last_2_days
      t.string :counter_data, :limit => 2048
    end
  end

  def self.down
    drop_table :counters
  end
end
