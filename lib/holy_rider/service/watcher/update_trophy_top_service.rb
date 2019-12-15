# frozen_string_literal: true

module HolyRider
  module Service
    module Watcher
      class UpdateTrophyTopService
        def initialize(player_id:)
          @player = Player.find(id: player_id)
        end

        def call
          @player.update_trophy_points
        end
      end
    end
  end
end
