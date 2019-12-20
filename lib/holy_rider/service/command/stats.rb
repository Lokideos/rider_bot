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
          trophy_total = profile[:trophies][:total].count + profile[:hidden_trophies][:total].count
          message = ["<b>Профиль игрока #{trophy_account} (@#{telegram_name})</b>"]
          message << "<code>PSN level           #{profile[:trophy_level]}</code>"
          message << "<code>Level up progress   #{profile[:level_up_progress]}</code>"
          message << "<code>Количество игр      #{profile[:games].count}</code>"
          message << "<code>Всего трофеев       #{trophy_total}</code>"
          message << "<code>Уникальные платины  #{profile[:unique_platinums]}</code>"
          message << "<b>\nТрофеи:</b>"
          message << "<code>Платина             #{profile[:trophies][:platinum].count}</code>"
          message << "<code>Золото              #{profile[:trophies][:gold].count}</code>"
          message << "<code>Серебро             #{profile[:trophies][:silver].count}</code>"
          message << "<code>Бронза              #{profile[:trophies][:bronze].count}</code>"
          message << "<code>Всего               #{profile[:trophies][:total].count}</code>"
          if profile[:hidden_trophies][:total].count.zero?
            message << "\n<b>Скрытые трофеи:</b>  #{player_name} скрывать нечего!"
          else
            message << "<b>\nСкрытые трофеи:</b>"
            message << "<code>Платина             #{profile[:hidden_trophies][:platinum].count}</code>"
            message << "<code>Золото              #{profile[:hidden_trophies][:gold].count}</code>"
            message << "<code>Серебро             #{profile[:hidden_trophies][:silver].count}</code>"
            message << "<code>Бронза              #{profile[:hidden_trophies][:bronze].count}</code>"
            message << "<code>Всего               #{profile[:hidden_trophies][:total].count}</code>"
          end

          [message.join("\n")]
        end
      end
    end
  end
end
