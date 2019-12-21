# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class TopGamesForceUpdate
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          player = Player.find(telegram_username: @command[@message_type]['from']['username'])
          return unless player.admin?

          Game.update_all_progress_caches
          message = ['Топы по играм были успешно обновлены']

          [message.join("\n")]
        end
      end
    end
  end
end
