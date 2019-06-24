require_relative "config/environment"

if ENV['RACK_ENV'] == 'development'
  require 'rack/unreloader'
  unreloader = Rack::Unreloader.new{HolyRider}
  unreloader.require '.config/'
  Dir.glob('lib/**/*.rb').each { |file_name| unreloader.require(file_name) }
  run unreloader
else
  run HolyRider.application
end
