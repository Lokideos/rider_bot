# frozen_string_literal: true

require 'roda'
require 'singleton'
require_relative 'roda_tree'
require_relative 'configuration'

module HolyRider
  class Application
    include Singleton

    attr_reader :db

    def initialize
      @db = nil
    end

    def bootstrap!
      @config = HolyRider::Configuration.instance.config
      setup_database
      setup_routing_tree
    end

    def call(env)
      HolyRider::RodaTree.call(env)
    end

    def setup_database
      @db = Sequel.connect(database_url)
    end

    def setup_routing_tree
      return HolyRider::RodaTree.freeze.app if ENV['RACK_ENV'] == 'production'

      HolyRider::RodaTree.app
    end

    private

    def database_url
      database = "holy_rider_#{ENV['RACK_ENV']}"

      @config[:database][:database_url] + "/#{database}"
    end
  end
end
