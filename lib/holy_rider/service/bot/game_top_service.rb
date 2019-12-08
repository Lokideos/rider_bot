# frozen_string_literal: true

module HolyRider
  module Service
    module Bot
      class GameTopService
        MAX_NAME_LENGTH = 20
        MAX_PROGRESS_LENGTH = 4

        def initialize(top:)
          @top = top
        end

        def call
          game_top = []
          @top[:progresses].each do |progress|
            player_name = progress[:trophy_account]
            player_name = player_name[0..16] + '...' if player_name.length > 17
            player_progress = progress[:progress]
            platinum_trophy = nil
            if @top[:platinum] && !@top[:platinum].empty?
              if @top[:platinum].find { |trophy| trophy.trophy_account == player_name }
                platinum_trophy = "\xF0\x9F\x8F\x86"
              end
            end
            game_top << "<code>#{player_name} " + ' ' * (MAX_NAME_LENGTH - player_name.length) +
                        "#{player_progress}</code>" +
                        ' ' * (MAX_PROGRESS_LENGTH - player_progress.to_s.length) +
                        platinum_trophy.to_s
          end

          game_top.join("\n")
        end
      end
    end
  end
end
