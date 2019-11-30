# frozen_string_literal: true

module HolyRider
  module Service
    module Bot
      class SendChatMessageService
        def initialize(chat_id: nil, message: nil, client: nil)
          @chat_id = chat_id
          @message = message
          @client = client || HolyRider::Client::Telegram.new
        end

        def call
          @client.send_message(chat_id: @chat_id, message: @message)
        end
      end
    end
  end
end
