# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class Top
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        # TODO: refactoring needed
        def call
          message = ['<b>Топ трофеев:</b>']
          Player.trophy_top.each do |player_trophies|
            max_name_length = 15
            name = player_trophies[:trophy_account] || player_trophies[:telegram_username]
            name = name[0..11] + '...' if name.length > 12
            message << "<code>#{name}" + ' ' * (max_name_length - name.length) +
                       " #{player_trophies[:points]}</code>"
          end

          [message.join("\n")]
        end
      end
    end
  end
end
