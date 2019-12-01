# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessMention
      include Sidekiq::Worker
      sidekiq_options queue: :mentions, retry: 2, backtrace: 20

      def perform(chat_id, mention, message_type)
        message = 'Привет, Мастер.' if mention[message_type]['text'].include? 'привет'

        return unless message

        HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                            message: message).call
      end
    end
  end
end
