require 'rubygems'
gem 'require'
require 'require'

Require do
  gem(:active_wrapper, '=0.2.7') { require 'active_wrapper' }
  gem :require, '=0.2.7'
  gem(:rake, '=0.8.7') { require 'rake' }
  gem :rspec, '=1.3.0'
  
  gemspec do
    author 'Winton Welsh'
    dependencies do
      gem :active_wrapper
      gem :require
    end
    email 'mail@wintoni.us'
    name 'periodic_counter'
    homepage "http://github.com/winton/#{name}"
    summary ""
    version '0.1.0'
  end
  
  bin { require 'lib/periodic_counter' }
  
  lib do
    gem :active_wrapper
    require 'yaml'
  end
  
  rakefile do
    gem(:rake) { require 'rake/gempackagetask' }
    gem(:rspec) { require 'spec/rake/spectask' }
    require 'require/tasks'
  end
  
  spec_helper do
    require 'require/spec_helper'
    require 'lib/periodic_counter'
    require 'pp'
  end
end
