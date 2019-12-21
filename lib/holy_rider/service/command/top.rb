# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class Top
        MAX_NAME_LENGTH = 15
        MAX_PLACEMENT_LENGTH = 3

        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        # TODO: refactoring needed
        def call
          message = ['<b>Топ трофеев:</b>']
          Player.trophy_top.each_with_index do |player_trophies, index|
            name = player_trophies[:telegram_username]
            name = name[0..14] + '...' if name.length > 15
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
