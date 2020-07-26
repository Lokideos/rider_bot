# frozen_string_literal: true

module HolyRider
  module Service
    module Bot
      class UploadImageService
        def initialize(chat_id: nil, filepath:, player_name:, client: nil)
          @chat_id = chat_id || ENV['PS_CHAT_ID']
          @filepath = filepath
          @player_name = player_name
          @client = client || HolyRider::Client::Telegram.new
        end

        def call
          caption = "<code>#{@player_name}</code> присылает скриншот"
          @client.send_image(chat_id: @chat_id, filepath: @filepath, caption: caption)
        end
      end
    end
  end
end
