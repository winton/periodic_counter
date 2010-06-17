require 'spec_helper'

describe PeriodicCounter do
  
  before(:all) do
    $db.migrate(1)
    $db.migrate(0)
    $db.migrate(1)
    stub_time(PeriodicCounter.last_monday)
    create_counter
  end
  
  it "should set up data and increment last_monday (today)" do
    start
    attributes = Counter.last.attributes
    data = attributes.delete('counter_data')
    data.delete('counter_last_day_at').to_s.should == PeriodicCounter.today.to_s
    data.delete('counter_last_2_days_at').to_s.should == PeriodicCounter.today.to_s
    data.should == {
      "counter_last_day"=>1,
      "counter_last_2_days"=>1,
      "counter_last_monday_before_today"=>0,
      "counter_last_tuesday_before_today"=>1,
      "counter_last_wednesday_before_today"=>1
    }
    attributes.should == {
      "id"=>1,
      "counter"=>1,
      "counter_last_day"=>0,
      "counter_last_2_days"=>0,
      "counter_last_monday"=>1,
      "counter_last_tuesday"=>0,
      "counter_last_wednesday"=>0
    }
  end
  
  it "should add to last_day, last_2_days, and last_monday counters on increment" do
    Counter.last.update_attribute :counter, 2
    start
    attributes = Counter.last.attributes
    data = attributes.delete('counter_data')
    data.delete('counter_last_day_at').to_s.should == PeriodicCounter.today.to_s
    data.delete('counter_last_2_days_at').to_s.should == PeriodicCounter.today.to_s
    data.should == {
      "counter_last_day"=>1,
      "counter_last_2_days"=>1,
      "counter_last_monday_before_today"=>0,
      "counter_last_tuesday_before_today"=>2,
      "counter_last_wednesday_before_today"=>2
    }
    attributes.should == {
      "id"=>1,
      "counter"=>2,
      "counter_last_day"=>1,
      "counter_last_2_days"=>1,
      "counter_last_monday"=>2,
      "counter_last_tuesday"=>0,
      "counter_last_wednesday"=>0
    }
  end
  
  it "should reset counter_last_day and increment last_tuesday" do
    Counter.last.update_attribute :counter, 3
    stub_time(Time.now + 1.day) # Tuesday
    start
    attributes = Counter.last.attributes
    data = attributes.delete('counter_data')
    data.delete('counter_last_day_at').to_s.should == PeriodicCounter.today.to_s
    data.delete('counter_last_2_days_at').to_s.should == (PeriodicCounter.today - 1.day).to_s
    data.should == {
      "counter_last_day"=>3,
      "counter_last_2_days"=>1,
      "counter_last_monday_before_today"=>3,
      "counter_last_tuesday_before_today"=>2,
      "counter_last_wednesday_before_today"=>3
    }
    attributes.should == {
      "id"=>1,
      "counter"=>3,
      "counter_last_day"=>0,
      "counter_last_2_days"=>2,
      "counter_last_monday"=>2,
      "counter_last_tuesday"=>1,
      "counter_last_wednesday"=>0
    }
  end
  
  it "should reset last_2_days and not touch last_wednesday" do
    Counter.last.update_attribute :counter, 4
    stub_time(Time.now + 2.days) # Thursday
    start
    attributes = Counter.last.attributes
    data = attributes.delete('counter_data')
    data.delete('counter_last_day_at').to_s.should == PeriodicCounter.today.to_s
    data.delete('counter_last_2_days_at').to_s.should == PeriodicCounter.today.to_s
    data.should == {
      "counter_last_day"=>4,
      "counter_last_2_days"=>4,
      "counter_last_monday_before_today"=>4,
      "counter_last_tuesday_before_today"=>4,
      "counter_last_wednesday_before_today"=>4
    }
    attributes.should == {
      "id"=>1,
      "counter"=>4,
      "counter_last_day"=>0,
      "counter_last_2_days"=>0,
      "counter_last_monday"=>2,
      "counter_last_tuesday"=>1,
      "counter_last_wednesday"=>0
    }
  end
end
