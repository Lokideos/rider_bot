# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class PlayerReload
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
          player = Player.find(telegram_username: username)
          return unless player

          player.trophy_acquisitions.each(&:delete)
          player.game_acquisitions.each(&:delete)
          player.reload

          @redis.set("holy_rider:watcher:players:initial_load:#{player.trophy_account}", 'initial')

          ["Данные игрока #{username} будут запрошены заново"]
        end
      end
    end
  end
end
