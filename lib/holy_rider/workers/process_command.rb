# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessCommand
      include Sidekiq::Worker
      sidekiq_options queue: :commands, retry: 2, backtrace: 20

      def perform(chat_id, command, message_type)
        message_text = command[message_type]['text']
        split_message = message_text.split(' ')

        if split_message.first.include?('@holy_rider_bot')
          actual_command = split_message.first.split('@').first
          split_message[0] = actual_command
        end

        case split_message.first
        when '/help'
          message = 'Список команд:'
        when '/hunter_credentials'
          name = split_message[1]
          hunter = TrophyHunter.find(name: name)
          message = "#{name} credentials: #{hunter.email} #{hunter.password}" if hunter
        when '/hunter_stats'
          hunters = TrophyHunter.all
          message = []
          message << "  Name     Active     Geared\n"
          hunters.each_with_index do |hunter, index|
            message << "#{index + 1}. #{hunter.name}, #{hunter.active?}, #{hunter.geared_up?}\n"
          end
          message = message.join
        when '/hunter_geared_up?'
          name = split_message[1]
          message = TrophyHunter.find(name: name)&.geared_up?
        when '/hunter_gear_up'
          name = split_message[1]
          ticket_id = split_message[2]
          code = split_message[3]
          trophy_hunter = TrophyHunter.find(name: name)
          result = trophy_hunter&.full_authentication(ticket_id, code)
          message = if result
                      "#{name} locked & load"
                    else
                      "#{name} не смог аутентифицроваться"
                    end
        when '/hunter_activate'
          name = split_message[1]
          trophy_hunter = TrophyHunter.find(name: name)
          trophy_hunter.activate
          message = "#{name} активирован"
        when '/hunter_deactivate'
          name = split_message[1]
          trophy_hunter = TrophyHunter.find(name: name)
          trophy_hunter.deactivate
          message = "#{name} деактивирован"
        when '/add_player'
          username = split_message[1]
          trophy_account = split_message[2]
          Player.create(telegram_username: username)
          if trophy_account
            Player.find(telegram_username: username).update(trophy_account: trophy_account,
                                                            on_watch: true)
            redis = HolyRider::Application.instance.redis
            redis.sadd('holy_rider:watcher:players', trophy_account)
            redis.set("holy_rider:watcher:players:initial_load:#{trophy_account}", 'initial')
          end
          player = Player.find(telegram_username: username)
          message = "#{username} создан" if player
        when '/link_player'
          username = split_message[1]
          trophy_account = split_message[2]
          Player.find(telegram_username: username).update(trophy_account: trophy_account,
                                                          on_watch: true)
          player = Player.where(telegram_username: username, trophy_account: trophy_account).first
          redis = HolyRider::Application.instance.redis
          redis.sadd('holy_rider:watcher:players', trophy_account)
          redis.set("holy_rider:watcher:players:initial_load:#{trophy_account}", 'initial')
          message = "Аккаунт для трофеев успешно связан с пользователем #{username}" if player
        when '/list_players'
          players = Player.order(:created_at)
          message = [
            "Список игроков:\n", "  Ник в Телеграм Аккаунт для трофеев Отслеживание статуса \n"
          ]
          players.each_with_index do |player, index|
            message << "#{index + 1}. #{player.telegram_username} #{player.trophy_account} " \
                       "#{player.on_watch?}\n"
          end
          message = message.join('')
        when '/find'
          game_title = split_message[1..-1].join(' ')
          top = Game.top_game(game_title)
          return unless top

          game_title = "<a href='#{top[:game].icon_url}'>" \
                       "#{top[:game].title} #{top[:game].platform}</a>"
          HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                              message: game_title).call

          message = HolyRider::Service::Bot::GameTopService.new(top: top).call
        when '/games'
          game_title = split_message[1..-1].join(' ')
          games_list = Game.relevant_games(game_title, command)
          return unless games_list

          message = []
          message << "<b>Найденные игры:</b>\n"
          games_list.each_with_index do |game, index|
            message << "/#{index + 1} <b>#{game}</b>"
          end

          message = message.join("\n")
        when '/1'
          index = split_message[0][1..-1]
          player = command['message']['from']['username']
          top = Game.find_game_from_cache(player, index)
          return unless top

          game_title = "<a href='#{top[:game].icon_url}'>" \
                       "#{top[:game].title} #{top[:game].platform}</a>"
          HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                              message: game_title).call

          message = HolyRider::Service::Bot::GameTopService.new(top: top).call
        when '/2'
          index = split_message[0][1..-1]
          player = command['message']['from']['username']
          top = Game.find_game_from_cache(player, index)
          return unless top

          game_title = "<a href='#{top[:game].icon_url}'>" \
                       "#{top[:game].title} #{top[:game].platform}</a>"
          HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                              message: game_title).call

          message = HolyRider::Service::Bot::GameTopService.new(top: top).call
        when '/3'
          index = split_message[0][1..-1]
          player = command['message']['from']['username']
          top = Game.find_game_from_cache(player, index)
          return unless top

          game_title = "<a href='#{top[:game].icon_url}'>" \
                       "#{top[:game].title} #{top[:game].platform}</a>"
          HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                              message: game_title).call

          message = HolyRider::Service::Bot::GameTopService.new(top: top).call
        when '/4'
          index = split_message[0][1..-1]
          player = command['message']['from']['username']
          top = Game.find_game_from_cache(player, index)
          return unless top

          game_title = "<a href='#{top[:game].icon_url}'>" \
                       "#{top[:game].title} #{top[:game].platform}</a>"
          HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                              message: game_title).call

          message = HolyRider::Service::Bot::GameTopService.new(top: top).call
        when '/5'
          index = split_message[0][1..-1]
          player = command['message']['from']['username']
          top = Game.find_game_from_cache(player, index)
          return unless top

          game_title = "<a href='#{top[:game].icon_url}'>" \
                       "#{top[:game].title} #{top[:game].platform}</a>"
          HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                              message: game_title).call

          message = HolyRider::Service::Bot::GameTopService.new(top: top).call
        when '/6'
          index = split_message[0][1..-1]
          player = command['message']['from']['username']
          top = Game.find_game_from_cache(player, index)
          return unless top

          game_title = "<a href='#{top[:game].icon_url}'>" \
                       "#{top[:game].title} #{top[:game].platform}</a>"
          HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                              message: game_title).call

          message = HolyRider::Service::Bot::GameTopService.new(top: top).call
        when '/7'
          index = split_message[0][1..-1]
          player = command['message']['from']['username']
          top = Game.find_game_from_cache(player, index)
          return unless top

          game_title = "<a href='#{top[:game].icon_url}'>" \
                       "#{top[:game].title} #{top[:game].platform}</a>"
          HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                              message: game_title).call

          message = HolyRider::Service::Bot::GameTopService.new(top: top).call
        when '/8'
          index = split_message[0][1..-1]
          player = command['message']['from']['username']
          top = Game.find_game_from_cache(player, index)
          return unless top

          game_title = "<a href='#{top[:game].icon_url}'>" \
                       "#{top[:game].title} #{top[:game].platform}</a>"
          HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                              message: game_title).call

          message = HolyRider::Service::Bot::GameTopService.new(top: top).call
        when '/9'
          index = split_message[0][1..-1]
          player = command['message']['from']['username']
          top = Game.find_game_from_cache(player, index)
          return unless top

          game_title = "<a href='#{top[:game].icon_url}'>" \
                       "#{top[:game].title} #{top[:game].platform}</a>"
          HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                              message: game_title).call

          message = HolyRider::Service::Bot::GameTopService.new(top: top).call
        when '/10'
          index = split_message[0][1..-1]
          player = command['message']['from']['username']
          top = Game.find_game_from_cache(player, index)
          return unless top

          game_title = "<a href='#{top[:game].icon_url}'>" \
                       "#{top[:game].title} #{top[:game].platform}</a>"
          HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                              message: game_title).call

          message = HolyRider::Service::Bot::GameTopService.new(top: top).call
          # TODO: refactoring
        when '/top'
          message = ["<b>Топ трофеев:\n\n</b>"]
          Player.trophy_top.each do |player_trophies|
            max_name_length = 15
            name = player_trophies[:name]
            name = name[0..11] + '...' if name.length > 12
            message << "<code>#{player_trophies[:name]}" + ' ' * (max_name_length - name.length) +
              " #{player_trophies[:points]}\n</code>"
          end

          message = message.join
        when '/me'
          player = Player.find(telegram_username: command['message']['from']['username'])
          profile = player.profile
          trophy_account = player.trophy_account
          telegram_name = player.telegram_username
          message = ["<b>Профиль игрока #{trophy_account} (@#{telegram_name})</b>\n"]
          message << "<code>Количество игр    #{profile[:games].count}</code>\n"
          message << "<code>Платиновые трофеи #{profile[:trophies][:platinum].count}</code>\n"
          message << "<code>Золотые трофеи    #{profile[:trophies][:gold].count}</code>\n"
          message << "<code>Серебряные трофеи #{profile[:trophies][:silver].count}</code>\n"
          message << "<code>Бронзовые трофеи  #{profile[:trophies][:bronze].count}</code>\n"

          message = message.join
        end

        return unless message

        HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                            message: message).call
      end
    end
  end
end
