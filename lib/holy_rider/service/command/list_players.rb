# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class ListPlayers
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          return unless Player.find(telegram_username: @command[@message_type]['from']['username'])

          players = Player.order(:created_at)
          message = [
            'Список игроков:', '  Ник в Телеграм Аккаунт для трофеев Отслеживание статуса'
          ]
          players.each_with_index do |player, index|
            message << "#{index + 1}. #{player.telegram_username} #{player.trophy_account} " \
                       "#{player.on_watch?}"
          end

          [message.join("\n")]
        end
      end
    end
  end
end
