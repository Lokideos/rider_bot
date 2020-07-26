# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class PlayerAdd
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
          @redis = HolyRider::Application.instance.redis
        end

        def call
          player = Player.find(telegram_username: @command[@message_type]['from']['username'])
          return unless player.admin?

          message = @command[@message_type]['text'].split(' ')
          username = message[1]
          trophy_account = message[2]
          return unless username

          Player.create(telegram_username: username)
          return successful_message(username) unless trophy_account

          Player.find(telegram_username: username).update(trophy_account: trophy_account,
                                                          message_thread_name: trophy_account,
                                                          on_watch: true)
          @redis.sadd('holy_rider:watcher:players', trophy_account)
          @redis.set("holy_rider:watcher:players:initial_load:#{trophy_account}", 'initial')

          successful_message(username)
        end

        private

        def successful_message(username)
          ["#{username} создан"]
        end
      end
    end
  end
end
