# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class Me
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          player = Player.find(telegram_username: @command['message']['from']['username'])
          profile = player.profile
          trophy_account = player.trophy_account
          telegram_name = player.telegram_username
          message = ["<b>Профиль игрока #{trophy_account} (@#{telegram_name})</b>"]
          message << "<code>PSN level         #{profile[:trophy_level]}</code>"
          message << "<code>Level up progress #{profile[:level_up_progress]}</code>"
          message << "<code>Количество игр    #{profile[:games].count}</code>"
          message << "<b>\nТрофеи:</b>"
          message << "<code>Платиновые трофеи #{profile[:trophies][:platinum].count}</code>"
          message << "<code>Золотые трофеи    #{profile[:trophies][:gold].count}</code>"
          message << "<code>Серебряные трофеи #{profile[:trophies][:silver].count}</code>"
          message << "<code>Бронзовые трофеи  #{profile[:trophies][:bronze].count}</code>"
          message << "<code>Всего трофеев     #{profile[:trophies][:total].count}</code>"
          message << "\n<b>Скрытые трофеи:</b>"
          message << "<code>Платиновые трофеи #{profile[:hidden_trophies][:platinum].count}</code>"
          message << "<code>Золотые трофеи    #{profile[:hidden_trophies][:gold].count}</code>"
          message << "<code>Серебряные трофеи #{profile[:hidden_trophies][:silver].count}</code>"
          message << "<code>Бронзовые трофеи  #{profile[:hidden_trophies][:bronze].count}</code>"
          message << "<code>Всего трофеев     #{profile[:hidden_trophies][:total].count}</code>"

          [message.join("\n")]
        end
      end
    end
  end
end
