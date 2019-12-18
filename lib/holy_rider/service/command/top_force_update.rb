# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class TopForceUpdate
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          player = Player.find(telegram_username: @command[@message_type]['from']['username'])
          return unless player.admin?

          updated_top = Player.trophy_top_force_update
          message = ['Топ трофеев был успешно обновлен']
          message << 'Обновленный топ трофеев:'
          updated_top.each do |player_trophies|
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
