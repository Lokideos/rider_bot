# frozen_string_literal: true

module HolyRider
  module Service
    module Bot
      class SendStickerService
        def initialize(chat_id: nil, sticker: nil, client: nil)
          @chat_id = chat_id
          @sticker = sticker
          @client = client || HolyRider::Client::Telegram.new
        end

        def call
          @client.send_sticker(chat_id: @chat_id, sticker: @sticker)
        end
      end
    end
  end
end
