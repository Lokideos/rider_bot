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

      def send_image(chat_id:, filepath:)
        payload = { photo: Faraday::UploadIO.new(File.open(filepath), 'image/jpeg') }

        build_connection.post("/bot#{@chat_bot.token}/sendPhoto?chat_id=#{chat_id}",
                              payload) do |request|
          request.headers['Content-Type'] = 'multipart/form-data'
        end
      end

      private

      def sticker_url(chat_id, sticker)
        "https://api.telegram.org/bot#{@chat_bot.token}/sendSticker?" \
          "chat_id=#{chat_id}&" \
          "sticker=#{sticker}"
      end

      def file_url(chat_id)
        "https://api.telegram.org/bot#{@chat_bot.token}/savePhoto?chat_id=#{chat_id}"
      end

      def build_connection
        @connection ||= Faraday.new('https://api.telegram.org/') do |conn|
          conn.request :multipart
          conn.request :url_encoded
          conn.adapter :typhoeus
        end
      end
    end
  end
end
