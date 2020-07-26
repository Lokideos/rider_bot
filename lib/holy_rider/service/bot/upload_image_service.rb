# frozen_string_literal: true

module HolyRider
  module Service
    module Bot
      class UploadImageService
        def initialize(chat_id: nil, filepath:, client: nil)
          @chat_id = chat_id || ENV['PS_CHAT_ID']
          @filepath = filepath
          @client = client || HolyRider::Client::Telegram.new
        end

        def call
          @client.send_image(chat_id: @chat_id, filepath: @filepath)
        end
      end
    end
  end
end
