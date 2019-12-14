# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class Stats
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          text = @command[@message_type]['text']
          player_name = text.include?('@') ? text.split(' ')[1][1..-1] : text.split(' ')[1]
          player = Player.find(telegram_username: player_name)
          return unless player

          profile = player.profile
          trophy_account = player.trophy_account
          telegram_name = player.telegram_username
          message = ["<b>Профиль игрока #{trophy_account} (@#{telegram_name})</b>"]
          message << "<code>Количество игр    #{profile[:games].count}</code>"
          message << "<code>Платиновые трофеи #{profile[:trophies][:platinum].count}</code>"
          message << "<code>Золотые трофеи    #{profile[:trophies][:gold].count}</code>"
          message << "<code>Серебряные трофеи #{profile[:trophies][:silver].count}</code>"
          message << "<code>Бронзовые трофеи  #{profile[:trophies][:bronze].count}</code>"

          [message.join("\n")]
        end
      end
    end
  end
end
