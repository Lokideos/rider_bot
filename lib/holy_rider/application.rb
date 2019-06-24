# frozen_string_literal: true

require 'roda'
require 'dotenv'

module HolyRider
  class Application < Roda
    def self.bootstrap!
      # setup database

      return if ENV['RACK_ENV'] == 'production'

      dotenv = ".env.#{ENV['RACK_ENV']}"

      raise "#{dotenv} not found! #{dotenv} is required to start in #{ENV['RACK_ENV']} mode!" unless File.exist?(dotenv)

      Dotenv.load(dotenv)
    end
  end
end
