# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class PlayerRename
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          player = Player.find(telegram_username: @command[@message_type]['from']['username'])
          return unless player.admin?

          message = @command[@message_type]['text'].split(' ')
          username = message[1]
          player = Player.find(telegram_username: username)
          return ["Игрок #{username} не найден"] unless player

          new_username = message[2]
          return ['Введите корректный никнейм'] unless new_username

          player.update(telegram_username: new_username)

          ["Игрок #{username} успешно переименован в #{new_username}"]
        end
      end
    end
  end
end
