require 'bundler/setup'
Bundler.require(:default, :development)

require 'sinatra'

disable :run

require './app'
run App.run!

