# frozen_string_literal: true

require 'roda'
require 'singleton'
require 'redis'
require 'oj'
require_relative 'roda_tree'
require_relative 'configuration'
require_relative 'client/telegram'
require_relative 'bot'

module HolyRider
  class Application
    include Singleton

    attr_reader :db, :redis, :app_type

    def initialize
      @db = nil
      @redis = nil
      @app_type = ENV['APP_TYPE']
    end

    def bootstrap!
      @config = HolyRider::Configuration.instance.config
      setup_database
      setup_redis
      case app_type
      when 'bots'
        setup_telegram_bot
        HolyRider::Bot.application
      else
        # TODO: remove setup bot from web before release
        setup_telegram_bot
        setup_routing_tree
      end
    end

    def setup_telegram_bot
      HolyRider::Client::Telegram.bootstrap_bots_configuration
    end

    def call(env)
      HolyRider::RodaTree.call(env)
    end

    def setup_database
      @db = Sequel.connect(database_url)
    end

    def setup_redis
      @redis = Redis.new(host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'])
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
