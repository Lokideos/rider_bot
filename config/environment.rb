# frozen_string_literal: true

require 'dotenv'
require_relative '../lib/holy_rider'

unless ENV['RACK_ENV'] == 'production'
  dotenv = ".env.#{ENV['RACK_ENV']}"
  #raise "#{dotenv} not found! #{dotenv} is required to start in #{ENV['RACK_ENV']} mode!" unless File.exist?(dotenv)

  Dotenv.load(dotenv)
end

HolyRider.application.bootstrap!
