require 'bundler'
Bundler.require

require File.expand_path('../enroll/config/environment',  __FILE__)

run EnrollerApp
