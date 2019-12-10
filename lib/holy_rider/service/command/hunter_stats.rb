# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class HunterStats
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          player = Player.find(telegram_username: @command[@message_type]['from']['username'])
          return unless player.admin?

          hunters = TrophyHunter.all
          message = []
          message << "  Name     Active     Geared\n"
          hunters.each_with_index do |hunter, index|
            message << "#{index + 1}. #{hunter.name}, #{hunter.active?}, #{hunter.geared_up?}\n"
          end

          [message.join]
        end
      end
    end
  end
end
