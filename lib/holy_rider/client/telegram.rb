# frozen_string_literal: true

require 'telegram/bot'
require 'typhoeus'

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
        @redis = HolyRider::Application.instance.redis
      end

      def get_updates
        offset_value = @redis.get('holy_rider:telegram:offset')
        updates = chat_bot.get_updates(offset: offset_value || '')
        unless updates['result'].empty?
          last_update_id = chat_bot.get_updates['result'].last['update_id']
          @redis.set('holy_rider:telegram:offset', last_update_id)
        end

        updates
      end

      def send_message(chat_id:, message:)
        chat_bot.send_message(chat_id: chat_id, text: message, parse_mode: 'html')
      end

      def delete_message(chat_id:, message_id:)
        chat_bot.delete_message(chat_id: chat_id, message_id: message_id)
      end

      def send_sticker(chat_id:, sticker:)
        Typhoeus::Request.new(sticker_url(chat_id, sticker), method: :post).run
      end

      private

      def sticker_url(chat_id, sticker)
        "https://api.telegram.org/bot#{@chat_bot.token}/sendSticker?" \
          "chat_id=#{chat_id}&" \
          "sticker=#{sticker}"
      end
    end
  end
end
