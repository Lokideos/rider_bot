# frozen_string_literal: true

module HolyRider
  module Service
    module Watcher
      class NewTrophiesService
        def initialize(player_name:, token:, updates:, hunter_name:)
          @player = Player.find(trophy_account: player_name)
          @token = token
          @updates = updates
          @hunter_name = hunter_name
          @redis = HolyRider::Application.instance.redis
          @initial = @redis.get("holy_rider:watcher:players:#{player_name}")
        end

        def call
          # TODO: find better name for fuck sake
          games_trophy_progresses = @updates['trophyTitles'].map do |game|
            {
              trophy_service_id: game.dig('npCommunicationId'),
              progress: game.dig('comparedUser', 'progress'),
              last_updated_date: game.dig('comparedUser', 'lastUpdateDate')
            }
          end

          games_trophy_progresses.each do |trophy_progress|
            game = Game.find(trophy_service_id: trophy_progress[:trophy_service_id])
            game_acquistion = game.game_acquisitions.find do |acquisition|
              acquisition.player_id == @player.id
            end

            trophy_service_update_date = Time.parse(trophy_progress[:last_updated_date]) -
                                         Time.now.getlocal.utc_offset
            watcher_update_date = game_acquistion.last_updated_date&.utc
            next if trophy_service_update_date == watcher_update_date

            game_acquistion.update(progress: trophy_progress[:progress],
                                   last_updated_date: trophy_progress[:last_updated_date])

            HolyRider::Workers::ProcessTrophiesList.perform_async(@player.id,
                                                                  game.id,
                                                                  trophy_progress[:trophy_service_id],
                                                                  @initial)
          end
        end
      end
    end
  end
end
