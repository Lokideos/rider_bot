# frozen_string_literal: true

require 'telegram/bot'

module HolyRider
  module Client
    class Telegram
      attr_reader :chat_bot

      class << self
        def bootstrap_bots_configuration
          ::Telegram.bots_config = { default: ENV['BOT_TOKEN'],
                                     chat: { token: ENV['BOT_TOKEN'],
                                             username: ENV['BOT_USERNAME'] } }
        end
      end

      def initialize
        @chat_bot = ::Telegram.bots[:chat]
      end

      def get_updates
        chat_bot.get_updates
      end

      def send_message(chat_id:, message:)
        chat_bot.send_message(chat_id: chat_id, text: message)
      end
    end
  end
end
