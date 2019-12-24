# frozen_string_literal: true

module HolyRider
  module Service
    module Watcher
      class CorrectGameTrophiesService
        def initialize(player:, token:, game:, new_trophy_ids:)
          @player = player
          @token = token
          @game = game
          @new_trophy_ids = new_trophy_ids
          @trophies_list_service = HolyRider::Service::PSN::RequestTrophiesListService
        end

        def call
          extended_trophies_list = @trophies_list_service.new(player_name: @player.trophy_account,
                                                              token: @token,
                                                              trophy_service_id: @game.trophy_service_id,
                                                              extended: true).call

          new_trophies = extended_trophies_list.select do |trophy|
            @new_trophy_ids.include? trophy['trophyId']
          end

          HolyRider::Worker::ProcessProgressesUpdate.perform_async(@game.id)

          new_trophies.each do |trophy|
            @game.add_trophy(Trophy.create(trophy_name: trophy['trophyName'],
                                           trophy_service_id: trophy['trophyId'],
                                           trophy_description: trophy['trophyDetail'],
                                           trophy_type: trophy['trophyType'],
                                           trophy_icon_url: trophy['trophyIconUrl'],
                                           trophy_small_icon_url: trophy['trophySmallIconUrl'],
                                           trophy_earned_rate: trophy['trophyEarnedRate'],
                                           trophy_rare: trophy['trophyRare']))
          end
        end
      end
    end
  end
end
