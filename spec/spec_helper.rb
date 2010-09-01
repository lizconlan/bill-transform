#require File.join(File.dirname(__FILE__), '..', 'server.rb')
require File.join(File.dirname(__FILE__), '..', 'lib/html_bill.rb')


require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'spec'
require 'spec/autorun'
require 'spec/interop/test'

# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false