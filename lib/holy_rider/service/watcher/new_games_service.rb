# frozen_string_literal: true

module HolyRider
  module Service
    module Watcher
      class NewGamesService
        def initialize(player_name:, token:, updates:)
          @player = Player.find(trophy_account: player_name)
          @token = token
          @updates = updates
          @trophies_list_service = HolyRider::Service::PSN::RequestTrophiesListService
        end

        def call
          trophy_service_ids = @updates['trophyTitles'].map { |game| game['npCommunicationId'] }
          new_games_trophy_ids = trophy_service_ids - Game.map(:trophy_service_id)

          new_games_trophy_ids.each do |id|
            new_game = @updates['trophyTitles'].find { |game| game['npCommunicationId'] == id }
            extended_trophies_list = @trophies_list_service.new(player_name: @player.trophy_account,
                                                                token: @token,
                                                                trophy_service_id: id,
                                                                extended: true).call
            game = Game.create(trophy_service_id: id, title: new_game['trophyTitleName'],
                               platform: new_game['trophyTitlePlatfrom'],
                               icon_url: new_game['trophyTitleIconUrl'])

            # TODO: find import (bulk_upload) in sequel and use it to query all trophies to db
            extended_trophies_list.each do |trophy|
              game.add_trophy(Trophy.create(trophy_name: trophy['trophyName'],
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
end
