# frozen_string_literal: true

module HolyRider
  module Service
    module Watcher
      class NewTrophiesService
        def initialize(player_name:, updates:, hunter_name:)
          @player = Player.find(trophy_account: player_name)
          @player_name = player_name
          @updates = updates
          @hunter_name = hunter_name
          @redis = HolyRider::Application.instance.redis
          @initial = @redis.get("holy_rider:watcher:players:initial_load:#{player_name}")
          @hidden_check = @redis.get("holy_rider:watcher:players:hidden_check:#{player_name}")
          @hidden_trophy_service = HolyRider::Service::Watcher::AddHiddenTrophiesService
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

          unless @initial
            service_ids = games_trophy_progresses.map { |progress| progress[:trophy_service_id] }
            current_game_status_dates = Player.where(trophy_account: @player_name).inner_join(:game_acquisitions, player_id: :id).inner_join(:games, id: :game_id).where(trophy_service_id: service_ids).map(:last_updated_date).map(&:utc).sort
            psn_game_status_dates = games_trophy_progresses.map do |progress|
              progress[:last_updated_date]
            end
            prepared_psn_dates = psn_game_status_dates.map do |date|
              Time.parse(date) - Time.now.getlocal.utc_offset
            end
            if prepared_psn_dates.all? { |date| current_game_status_dates.include? date }
              unless @hidden_check
                @hidden_trophy_service.new(player_name: @player_name,
                                           hunter_name: @hunter_name).call
                @redis.setex("holy_rider:watcher:players:hidden_check:#{@player_name}",
                             86_400,
                             'checked')
              end
              return
            end
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

            if @initial
              @redis.sadd("holy_rider:watcher:players:initial_load:#{@player_name}:trophies",
                          trophy_progress[:trophy_service_id])
              HolyRider::Workers::InitialProcessTrophiesList.perform_async(
                @player.id,
                game.id,
                trophy_progress[:trophy_service_id],
                @initial
              )
              next
            end

            HolyRider::Workers::ProcessTrophiesList.perform_async(
              @player.id,
              game.id,
              trophy_progress[:trophy_service_id],
              @initial
            )
          end
        end
      end
    end
  end
end
