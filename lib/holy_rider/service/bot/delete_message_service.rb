# frozen_string_literal: true

module HolyRider
  module Service
    module Bot
      class DeleteMessageService
        def initialize(message_uid:, client: nil)
          @message_uid = message_uid
          @client = client || HolyRider::Client::Telegram.new
          @redis = HolyRider::Application.instance.redis
        end

        def call
          message_info = @redis.hgetall("holy_rider:bot:messages:to_delete:info:#{@message_uid}")
          return if message_info.empty?

          @client.delete_message(chat_id: message_info['chat_id'],
                                 message_id: message_info['message_id'])

          @redis.srem('holy_rider:bot:messages:to_delete', @message_uid)
          @redis.del("holy_rider:bot:messages:to_delete:info:#{@message_uid}")
        end
      end
    end
  end
end
