# frozen_string_literal: true

module HolyRider
  module Watcher
    class Application
      include Singleton

      DEFAULT_TAINT_TIME = 10

      attr_reader :db, :redis

      def initialize
        @db = HolyRider::Application.instance.db
        @redis = HolyRider::Application.instance.redis
        @psn_updates_service = HolyRider::Service::PSN::RequestUpdatesService
        @new_games_service = HolyRider::Service::Watcher::NewGamesService
        @link_games_service = HolyRider::Service::Watcher::LinkGamesService
        @new_trophies_service = HolyRider::Service::Watcher::NewTrophiesService
        @redis.del('holy_rider:watcher:players')
        @redis.del('holy_rider:watcher:hunters')
        @redis.del('holy_rider:watcher:hunters:tainted')
        @hunters = TrophyHunter.active_hunters
        @hunters.each do |hunter|
          hunter_name = hunter.name
          @redis.sadd('holy_rider:watcher:hunters', hunter_name)
          hunter.store_access_token(hunter.authenticate)
        end
        active_trophy_accounts = Player.active_trophy_accounts
        @redis.sadd('holy_rider:watcher:players', Player.active_trophy_accounts) unless active_trophy_accounts.empty?
        watcher_loop
      end

      def watcher_loop
        loop do
          return p 'There are no hunters' if @hunters.empty?

          if @redis.smembers('holy_rider:watcher:players').empty?
            p 'There are no players'
            sleep(1)
            next
          end

          @redis.smembers('holy_rider:watcher:players').each do |player|
            hunter_name = nil
            until hunter_name
              hunter_name = @redis.smembers('holy_rider:watcher:hunters').find do |name|
                !@redis.get("holy_rider:watcher:hunters:#{name}:game_queue:tainted")
              end

              unless hunter_name
                p 'Watcher: all hunters are tainted at the moment'
                sleep(1)
              end
            end

            @redis.setex("holy_rider:watcher:hunters:#{hunter_name}:game_queue:tainted",
                         DEFAULT_TAINT_TIME + rand(1..3),
                         'tainted')

            unless @redis.get("holy_rider:trophy_hunter:#{hunter_name}:access_token")
              hunter = TrophyHunter.find(name: hunter_name)
              hunter.store_access_token(hunter.authenticate)
            end

            token = @redis.get("holy_rider:trophy_hunter:#{hunter_name}:access_token")

            psn_updates = @psn_updates_service.new(player_name: player, token: token).call

            @new_games_service.new(player_name: player, token: token, updates: psn_updates).call
            @link_games_service.new(player_name: player, updates: psn_updates).call
            @new_trophies_service.new(player_name: player,
                                      token: token,
                                      updates: psn_updates,
                                      hunter_name: hunter_name).call
          end
          p 'Watcher: request successful'
        end
      end

      private

      def store_hunter_access_key; end
    end
  end
end
