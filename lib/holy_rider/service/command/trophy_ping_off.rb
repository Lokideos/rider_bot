# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class TrophyPingOff
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          player = Player.find(telegram_username: @command['message']['from']['username'])
          message = ['Оповещения о новых трофеях уже выключены']
          return message unless player.trophy_ping_on?

          player.update(trophy_ping: false)

          ['Оповещения о новых трофеях выключены']
        end
      end
    end
  end
end
