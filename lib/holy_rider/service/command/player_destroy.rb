# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class PlayerDestroy
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
          return ["Игрок #{username} не найден"] unless player

          @redis.srem('holy_rider:watcher:players', player.trophy_account)
          player.remove_all_games
          player.remove_all_trophies
          player.delete

          ["Игрок #{username} был удален"]
        end
      end
    end
  end
end
