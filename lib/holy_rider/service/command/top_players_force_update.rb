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

          Player.trophy_top_force_update
          message = ['Топы трофеев были успешно обновлены']

          [message.join("\n")]
        end
      end
    end
  end
end
