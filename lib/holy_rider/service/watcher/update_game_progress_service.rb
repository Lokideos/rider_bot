# frozen_string_literal: true

module HolyRider
  module Service
    module Watcher
      class UpdateGameProgressService
        def initialize(game_acquisition_id:)
          @game_acquisition = GameAcquisition.find(id: game_acquisition_id)
          @player = @game_acquisition.player
          @game = @game_acquisition.game
          @redis = HolyRider::Application.instance.redis
          @client = HolyRider::Client::PSN::Trophy::AllTrophyTitles
        end

        def call
          # TODO: this part should be moved from here and other services to separate one
          hunter_name = nil
          until hunter_name
            hunter_name = @redis.smembers('holy_rider:watcher:hunters').find do |name|
              !@redis.get("holy_rider:watcher:hunters:#{name}:trophy_queue:tainted")
            end
            unless hunter_name
              p 'Watcher: All hunters are tainted. Waiting...'
              sleep(1)
            end
          end

          @redis.setex("holy_rider:watcher:hunters:#{hunter_name}:trophy_queue:tainted",
                       HolyRider::Watcher::Application::DEFAULT_TAINT_TIME - rand(3..5),
                       'tainted')

          token = @redis.get("holy_rider:trophy_hunter:#{hunter_name}:access_token")
          unless token
            hunter = TrophyHunter.find(name: hunter_name)
            hunter.store_access_token(hunter.authenticate)
            token = @redis.get("holy_rider:trophy_hunter:#{hunter_name}:access_token")
          end

          player_name = @player.trophy_account
          @redis.set("holy_rider:watcher:players:progress_update:#{player_name}", 'in_progress')
          games_list = @client.new(player_name: player_name, token: token)
          @redis.del("holy_rider:watcher:players:progress_update:#{player_name}")
          updated_game = games_list.find do |game|
            game['npCommunicationId'] == @game.trophy_service_id
          end
          new_game_progress = updated_game['comparedUser']['progress']
          @game_acquisition.update(progress: new_game_progress)
        end
      end
    end
  end
end
