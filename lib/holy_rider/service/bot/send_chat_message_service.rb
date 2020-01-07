# frozen_string_literal: true

module HolyRider
  module Service
    module Bot
      class SendChatMessageService
        # Should be same as expiration time in Game model for now
        DEFAULT_EXPIRATION_TIME = 300

        def initialize(chat_id: nil, message: nil, to_delete: false, client: nil)
          @chat_id = chat_id
          @message = message
          @to_delete = to_delete
          @client = client || HolyRider::Client::Telegram.new
        end

        def call
          message = @client.send_message(chat_id: @chat_id, message: @message)
          return message unless @to_delete

          set_up_deletion(message)
        end

        private

        def set_up_deletion(message)
          message_id = message.dig('result', 'message_id')
          uid = Digest::SHA2.new.hexdigest([@chat_id, message_id].join)
          redis = HolyRider::Application.instance.redis
          redis.sadd('holy_rider:bot:messages:to_delete', uid)
          redis.setex("holy_rider:bot:messages:to_delete:expiration:#{uid}",
                      DEFAULT_EXPIRATION_TIME,
                      'present')
          message_info = { chat_id: @chat_id, message_id: message_id }
          redis.hmset("holy_rider:bot:messages:to_delete:info:#{uid}", message_info.flatten)
        end
      end
    end
  end
end
