# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessCommand
      include Sidekiq::Worker
      sidekiq_options queue: :commands, retry: 2, backtrace: 20

      def perform(chat_id, command, message_type)
        message_text = command[message_type]['text']
        split_message = message_text.split(' ')

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
        when '/add_player'
          username = split_message[1]
          trophy_account = split_message[2]
          Player.create(telegram_username: username)
          if trophy_account
            Player.find(telegram_username: username).update(trophy_account: trophy_account,
                                                            on_watch: true)
            redis = HolyRider::Application.instance.redis
            redis.sadd('holy_rider:watcher:players', trophy_account)
          end
          player = Player.find(telegram_username: username)
          message = "#{username} создан" if player
        when '/link_player'
          username = split_message[1]
          trophy_account = split_message[2]
          Player.find(telegram_username: username).update(trophy_account: trophy_account,
                                                          on_watch: true)
          player = Player.where(telegram_username: username, trophy_account: trophy_account).first
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
        end

        return unless message

        HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                            message: message).call
      end
    end
  end
end
