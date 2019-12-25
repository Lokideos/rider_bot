# frozen_string_literal: true

module HolyRider
  module Service
    module Watcher
      class ProcessTrophiesListService
        TROPHY_TYPES = %w[bronze silver gold platinum].freeze

        def initialize(player_id, game_id, trophy_service_id, initial)
          @player = Player.find(id: player_id)
          @game = Game.find(id: game_id)
          @trophy_service_id = trophy_service_id
          @initial = initial
          @redis = HolyRider::Application.instance.redis
          @correct_game_trophies_service = HolyRider::Service::Watcher::CorrectGameTrophiesService
          @update_trophy_rarity_service = HolyRider::Service::Watcher::UpdateTrophyRarityService
        end

        def call
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

          trophies_list_service = HolyRider::Service::PSN::RequestTrophiesListService
          trophies_list = trophies_list_service.new(player_name: @player.trophy_account,
                                                    token: token,
                                                    trophy_service_id: @trophy_service_id,
                                                    extended: true).call

          # TODO: here I check for new trophies (typically comes from DLC)
          # probably should move to separate service altogether
          all_new_trophy_ids = trophies_list.map { |trophy| trophy['trophyId'] }
          all_game_trophy_ids = @game.trophies.map(&:trophy_service_id)
          new_trophy_ids = all_new_trophy_ids - all_game_trophy_ids

          unless new_trophy_ids.empty?
            @correct_game_trophies_service.new(player: @player, token: token, game: @game,
                                               new_trophy_ids: new_trophy_ids).call
          end

          earned_trophies = trophies_list.select { |trophy| trophy.dig('comparedUser', 'earned') }

          if @initial
            @redis.setex("holy_rider:watcher:players:initial_load:#{@player.trophy_account}:trophy_count",
                         3600,
                         'initial_load')
          end

          earned_trophies_ids = earned_trophies.map { |trophy| trophy['trophyId'] }
          player_trophies = @player.trophies.select { |trophy| trophy.game_id == @game.id }

          new_earned_trophies_ids = earned_trophies_ids - player_trophies.map(&:trophy_service_id)

          # TODO: get rid of multiline block chaining
          earned_trophies_data = earned_trophies.select do |trophy|
            new_earned_trophies_ids.include? trophy['trophyId']
          end.map do |trophy|
            {
              trophy_service_id: trophy['trophyId'],
              trophy_earned_rate: trophy['trophyEarnedRate'],
              trophy_rare: trophy['trophyRare'],
              earned_at: trophy.dig('comparedUser', 'earnedDate')
            }
          end

          # Update rarity for current trophy, then enqueue current trophy worker
          unless @initial
            earned_trophies_data.each do |trophy_data|
              trophy = @game.trophies.find do |trophy|
                trophy.trophy_service_id == trophy_data[:trophy_service_id]
              end
              @update_trophy_rarity_service.new(trophy,
                                                trophy_data[:trophy_earned_rate],
                                                trophy_data[:trophy_rare]).call
            end
          end

          # TODO: find in Sequel better method to do this
          new_earned_trophies = new_earned_trophies_ids.map do |trophy_id|
            @game.trophies.find { |trophy| trophy.trophy_service_id == trophy_id }
          end.group_by(&:trophy_type)
          sorted_new_trophies = TROPHY_TYPES.map do |trophy_type|
            new_earned_trophies[trophy_type]
          end.flatten.compact

          sorted_new_trophies.each do |trophy|
            trophy_earning_time = earned_trophies_data.find do |trophy_date|
              trophy_date[:trophy_service_id] == trophy.trophy_service_id
            end[:earned_at]

            if @initial
              HolyRider::Workers::InitialProcessTrophy.perform_async(@player.id,
                                                                     trophy.id,
                                                                     trophy_earning_time,
                                                                     @initial)
              next
            end

            HolyRider::Workers::ProcessTrophy.perform_async(@player.id,
                                                            trophy.id,
                                                            trophy_earning_time,
                                                            @initial)
          end

          # Then update rarity for other trophies
          unless @initial
            not_earned_trophies_ids = all_new_trophy_ids - new_earned_trophies_ids
            not_earned_trophies_data = trophies_list.select do |trophy|
              not_earned_trophies_ids.include? trophy['trophyId']
            end.map do |trophy|
              {
                trophy_service_id: trophy['trophyId'],
                trophy_earned_rate: trophy['trophyEarnedRate'],
                trophy_rare: trophy['trophyRare']
              }
            end

            HolyRider::Workers::EnqueueTrophyRarityUpdates.perform_async(@game.id,
                                                                         not_earned_trophies_data)
          end

          @redis.srem("holy_rider:watcher:players:initial_load:#{@player.trophy_account}:trophies",
                      @trophy_service_id)

          if @redis.smembers("holy_rider:watcher:players:initial_load:#{@player.trophy_account}:trophies").empty?
            @redis.del("holy_rider:watcher:players:initial_load:#{@player.trophy_account}")
          end
        end
      end
    end
  end
end
