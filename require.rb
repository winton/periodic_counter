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
    summary "Maintains period fields on any counter column in your database"
    version '0.1.4'
  end
  
  bin { require 'lib/periodic_counter' }
  
  lib do
    gem :active_wrapper
    require 'yaml'
  end
  
  rakefile do
    gem(:active_wrapper)
    gem(:rake) { require 'rake/gempackagetask' }
    gem(:rspec) { require 'spec/rake/spectask' }
    require 'require/tasks'
  end
  
  spec_helper do
    gem(:active_wrapper)
    require 'require/spec_helper'
    require 'lib/periodic_counter'
    require 'pp'
  end
  
  spec_rakefile do
    gem(:rake)
    gem(:active_wrapper) { require 'active_wrapper/tasks' }
  end
end