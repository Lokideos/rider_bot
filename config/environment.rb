# frozen_string_literal: true

require 'dotenv'
require_relative '../lib/holy_rider'

unless ENV['RACK_ENV'] == 'production'
  dotenv = ".env.#{ENV['RACK_ENV']}"

  if ENV['RACK_ENV'] == 'development'
    raise "#{dotenv} not found! #{dotenv} is required to start in #{ENV['RACK_ENV']} mode!" unless File.exist?(dotenv)
  end

  Dotenv.load(dotenv)
end

HolyRider.application.bootstrap!
