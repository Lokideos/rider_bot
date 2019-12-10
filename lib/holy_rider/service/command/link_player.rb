# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class LinkPlayer
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
          @redis = HolyRider::Application.instance.redis
        end

        def call
          message = @command[@message_type]['text'].split(' ')
          username = message[1]
          trophy_account = message[2]
          player = Player.find(telegram_username: username)
          return unless player

          player.update(trophy_account: trophy_account, on_watch: true)
          @redis.sadd('holy_rider:watcher:players', trophy_account)
          @redis.set("holy_rider:watcher:players:initial_load:#{trophy_account}", 'initial')

          ["Аккаунт для трофеев успешно связан с пользователем #{username}"]
        end
      end
    end
  end
end
