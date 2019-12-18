# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class PlayerWatchOn
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
          @redis = HolyRider::Application.instance.redis
        end

        def call
          player = Player.find(telegram_username: @command[@message_type]['from']['username'])
          return unless player.admin?

          player_name = @command[@message_type]['text'].split(' ')[1]
          player = Player.find(telegram_username: player_name)
          message = ['Трофеи игрока уже отслеживаются']
          return message if player.on_watch?

          player.update(on_watch: true)
          @redis.sadd('holy_rider:watcher:players', player.trophy_account)

          ['Теперь трофеи игрока отслеживаются']
        end
      end
    end
  end
end
