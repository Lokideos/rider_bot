# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class HunterDeactivate
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          player = Player.find(telegram_username: @command[@message_type]['from']['username'])
          return unless player.admin?

          name = @command[@message_type]['text'].split(' ')[1]
          trophy_hunter = TrophyHunter.find(name: name)
          trophy_hunter.deactivate

          ["#{name} деактивирован"] unless trophy_hunter.active?
        end
      end
    end
  end
end
