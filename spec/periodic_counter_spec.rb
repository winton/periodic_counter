require 'spec_helper'

describe PeriodicCounter do
  describe "without starting value" do
    
    before(:each) do
      $db.migrate(1)
      $db.migrate(0)
      $db.migrate(1)
      create_counter
    end
    
    it "should add to counter_last_day" do
      stub_time(Time.now + 1.day)
      start
      Counter.last.counter_last_day.should == 2
      Counter.last.counter_last_2_days.should == 1
      Counter.last.counter_last_week.should == 1
      Counter.last.counter_last_2_weeks.should == 1
    end
    
    it "should add to counter_last_2_days" do
      stub_time(Time.now + 2.days)
      start
      Counter.last.counter_last_day.should == 2
      Counter.last.counter_last_2_days.should == 2
      Counter.last.counter_last_week.should == 1
      Counter.last.counter_last_2_weeks.should == 1
    end
    
    it "should add to counter_last_week" do
      stub_time(Time.now + 1.week)
      start
      Counter.last.counter_last_day.should == 2
      Counter.last.counter_last_2_days.should == 2
      Counter.last.counter_last_week.should == 2
      Counter.last.counter_last_2_weeks.should == 1
    end
    
    it "should add to counter_last_2_weeks" do
      stub_time(Time.now + 2.weeks)
      start
      Counter.last.counter_last_day.should == 2
      Counter.last.counter_last_2_days.should == 2
      Counter.last.counter_last_week.should == 2
      Counter.last.counter_last_2_weeks.should == 2
    end
  end
  
  describe "with starting value" do
    
    before(:each) do
      $db.migrate(2)
      $db.migrate(0)
      $db.migrate(2)
      Counter.reset_column_information
      create_counter
      start
      Counter.last.update_attribute :counter, 6
    end
    
    it "should add to counter_last_day" do
      stub_time(Time.now + 1.day)
      start
      Counter.last.counter_last_day.should == 2
      Counter.last.counter_last_2_days.should == 1
      Counter.last.counter_last_week.should == 1
      Counter.last.counter_last_2_weeks.should == 1
    end
    
    it "should add to counter_last_2_days" do
      stub_time(Time.now + 2.days)
      start
      Counter.last.counter_last_day.should == 2
      Counter.last.counter_last_2_days.should == 2
      Counter.last.counter_last_week.should == 1
      Counter.last.counter_last_2_weeks.should == 1
    end
    
    it "should add to counter_last_week" do
      stub_time(Time.now + 1.week)
      start
      Counter.last.counter_last_day.should == 2
      Counter.last.counter_last_2_days.should == 2
      Counter.last.counter_last_week.should == 2
      Counter.last.counter_last_2_weeks.should == 1
    end
    
    it "should add to counter_last_2_weeks" do
      stub_time(Time.now + 2.weeks)
      start
      Counter.last.counter_last_day.should == 2
      Counter.last.counter_last_2_days.should == 2
      Counter.last.counter_last_week.should == 2
      Counter.last.counter_last_2_weeks.should == 2
    end
  end
end
