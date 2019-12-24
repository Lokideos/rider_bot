# frozen_string_literal: true

module HolyRider
  module Service
    module Watcher
      class UpdateGameProgressesService
        def initialize(game_id:)
          @game = Game.find(id: game_id)
        end

        def call
          @game.update_top_progresses
        end
      end
    end
  end
end
