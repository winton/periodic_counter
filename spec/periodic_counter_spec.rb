require 'spec_helper'

describe PeriodicCounter do
  
  before(:all) do
    $db.migrate(1)
    $db.migrate(0)
    $db.migrate(1)
    create_counter
  end
  
  it "should not do anything but set up data" do
    start
    attributes = Counter.last.attributes
    data = attributes.delete('counter_data')
    data.delete('counter_last_day_at').to_s.should == Time.now.utc.to_s
    data.delete('counter_last_2_days_at').to_s.should == Time.now.utc.to_s
    data.should == {
      "counter_last_day"=>1,
      "counter_last_2_days"=>1
    }
    attributes.should == {
      "id"=>1,
      "counter"=>1,
      "counter_last_day"=>0,
      "counter_last_2_days"=>0
    }
  end
  
  it "should add to counter_last_day" do
    Counter.last.update_attribute :counter, 2
    stub_time(Time.now + 1.day)
    start
    attributes = Counter.last.attributes
    data = attributes.delete('counter_data')
    data.delete('counter_last_day_at').to_s.should == Time.now.utc.to_s
    data.delete('counter_last_2_days_at').to_s.should == (Time.now - 1.day).utc.to_s
    data.should == {
      "counter_last_day"=>2,
      "counter_last_2_days"=>1
    }
    attributes.should == {
      "id"=>1,
      "counter"=>2,
      "counter_last_day"=>1,
      "counter_last_2_days"=>0
    }
  end
  
  it "should add to counter_last_2_days" do
    Counter.last.update_attribute :counter, 3
    stub_time(Time.now + 2.days)
    start
    attributes = Counter.last.attributes
    data = attributes.delete('counter_data')
    data.delete('counter_last_day_at').to_s.should == Time.now.utc.to_s
    data.delete('counter_last_2_days_at').to_s.should == Time.now.utc.to_s
    data.should == {
      "counter_last_day"=>3,
      "counter_last_2_days"=>3
    }
    attributes.should == {
      "id"=>1,
      "counter"=>3,
      "counter_last_day"=>1,
      "counter_last_2_days"=>2
    }
  end
end
