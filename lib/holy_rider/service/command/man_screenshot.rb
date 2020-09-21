# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class ManScreenshot
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          message = ['<b>Загрузка скриншота</b>']
          message << 'Для загрузки скриншота отправьте его через psn на аккаунт бота.'
          message << "На данный момент это <code>#{ENV['SCREENSHOT_BOT_NAME']}</code>."
          message << 'Через какое-то время скриншот появится в чате с указанием на того, ' \
                     'кто его отправил.'

          [message.join("\n")]
        end
      end
    end
  end
end
