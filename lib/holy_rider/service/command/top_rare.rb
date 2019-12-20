# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class TopRare
        MAX_NAME_LENGTH = 18
        MAX_PLACEMENT_LENGTH = 3

        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        # TODO: refactoring needed
        def call
          message = ['<b>Топ редких трофеев:</b>']
          Player.trophy_top_rare.each_with_index do |player_trophies, index|
            name = player_trophies[:trophy_account] || player_trophies[:telegram_username]
            name = name[0..16] + '...' if name.length > 17
            placement = (index + 1).to_s
            message << "<code>#{placement}" +
                       ' ' * (MAX_PLACEMENT_LENGTH - placement.length) +
                       name +
                       ' ' * (MAX_NAME_LENGTH - name.length) +
                       " #{player_trophies[:points]}</code>"
          end

          [message.join("\n")]
        end
      end
    end
  end
end
