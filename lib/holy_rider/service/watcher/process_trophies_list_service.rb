# frozen_string_literal: true

module HolyRider
  module Service
    module Watcher
      class ProcessTrophiesListService
        def initialize(player_id, game_id, trophy_service_id, initial)
          @player = Player.find(id: player_id)
          @game = Game.find(id: game_id)
          @trophy_service_id = trophy_service_id
          @initial = initial
          @redis = HolyRider::Application.instance.redis
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
                                                    trophy_service_id: @trophy_service_id).call

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
          earned_trophies_dates = earned_trophies.select do |trophy|
            new_earned_trophies_ids.include? trophy['trophyId']
          end.map do |trophy|
            {
              trophy_service_id: trophy['trophyId'],
              earned_at: trophy.dig('comparedUser', 'earnedDate')
            }
          end

          # TODO: find in Sequel better method to do thisb
          new_earned_trophies = new_earned_trophies_ids.map do |trophy_id|
            @game.trophies.find { |trophy| trophy.trophy_service_id == trophy_id }
          end

          new_earned_trophies.each do |trophy|
            trophy_earning_time = earned_trophies_dates.find do |trophy_date|
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
