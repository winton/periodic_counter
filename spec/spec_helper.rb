require File.expand_path("#{File.dirname(__FILE__)}/../require")
Require.spec_helper!

Spec::Runner.configure do |config|
end

$db, $log, $mail = ActiveWrapper.setup(
  :base => File.dirname(__FILE__),
  :env => 'test'
)
$db.establish_connection

def create_counter
  Counter.create(
    :counter => 3,
    :counter_computed_at => Time.now,
    :counter_last_day => 1,
    :counter_last_2_days => 1,
    :counter_last_week => 1,
    :counter_last_2_weeks => 1
  )
end

def start
  PeriodicCounter.new('test', File.dirname(__FILE__))
end

def stub_time(time)
  Time.stub!(:now).and_return(time)
end

class Counter < ActiveRecord::Base
end