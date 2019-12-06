# frozen_string_literal: true

require 'roda'
require 'singleton'
require 'redis'
require 'oj'
require 'sidekiq'
require 'typhoeus'
require 'sequel'
require 'pry-byebug'

require_relative 'roda_tree'
require_relative 'configuration'
require_relative 'bot'
require_relative 'bot/application'
require_relative 'watcher'
require_relative 'watcher/application'
require_relative 'client/telegram'
require_relative 'client/psn/auth/access_token'
require_relative 'client/psn/auth/sso_cookie'
require_relative 'client/psn/auth/grant_code'
require_relative 'client/psn/auth/refresh_token'
require_relative 'client/psn/trophy/all_trophy_titles'
require_relative 'client/psn/trophy/game_trophy_titles'
require_relative 'workers/process_command'
require_relative 'workers/process_mention'
require_relative 'workers/process_trophies_list'
require_relative 'workers/process_trophy'
require_relative 'service/bot/chat_update_service'
require_relative 'service/bot/send_chat_message_service'
require_relative 'service/bot/process_command_service'
require_relative 'service/bot/process_mention_service'
require_relative 'service/psn/initial_authentication_service'
require_relative 'service/psn/update_access_token_service'
require_relative 'service/psn/request_updates_service'
require_relative 'service/psn/request_trophies_list_service'
require_relative 'service/watcher/new_games_service'
require_relative 'service/watcher/new_trophies_service'
require_relative 'service/watcher/link_games_service'

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
      setup_telegram_bot
      case app_type
      when 'bot'
        HolyRider::Bot.application
      when 'background'
        setup_background_backbone
      when 'watcher'
        HolyRider::Watcher.application
      else
        setup_routing_tree
      end
    end

    def setup_background_backbone
      redis_url = "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/1"
      Sidekiq.options[:dead_max_jobs] = 1_500_000
      Sidekiq.configure_client do |config|
        config.redis = { url: redis_url, db: 'background_backbone_db', network_timeout: 15 }
      end
      Sidekiq.configure_server do |config|
        config.redis = { url: redis_url, db: 'background_backbone_db', network_timeout: 15 }
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
      Sequel::Model.plugin :timestamps
      require_relative 'models/base_model'
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
