# frozen_string_literal: true

module HolyRider
  module Service
    module Watcher
      class UpdateTrophyRarityService
        def initialize(trophy, trophy_earned_rate, trophy_rare)
          @trophy = trophy
          @trophy_earned_rate = trophy_earned_rate
          @trophy_rare = trophy_rare
        end

        def call
          @trophy.update(trophy_earned_rate: @trophy_earned_rate, trophy_rare: @trophy_rare)
        end
      end
    end
  end
end
