# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class TrophyPingOn
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          player = Player.find(telegram_username: @command['message']['from']['username'])
          message = ['Оповещения о новых трофеях уже включены']
          return message if player.trophy_ping_on?

          player.update(trophy_ping: true)

          ['Оповещения о новых трофеях включены']
        end
      end
    end
  end
end
