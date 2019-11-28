# frozen_string_literal: true

module HolyRider
  module Service
    module Bot
      class ChatUpdateService
        def initialize(client: nil)
          @client = client || HolyRider::Client::Telegram.new
        end

        def call
          @client.get_updates
        end
      end
    end
  end
end
