# frozen_string_literal: true

module HolyRider
  module Service
    module Watcher
      class UpdateTrophyTopService
        def initialize(player_id:, trophy_id:)
          @player = Player.find(id: player_id)
          @trophy = Trophy.find(id: trophy_id)
        end

        def call
          @player.update_trophy_points
          @player.update_rare_points

          game = @trophy.game
          prepared_game = Game.find_exact_game(game.title, game.platform)
          Game.store_game_top(prepared_game)
        end
      end
    end
  end
end
