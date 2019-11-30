# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessCommand
      include Sidekiq::Worker
      sidekiq_options queue: :commands, retry: 2, backtrace: 20

      def perform(chat_id, message)
        HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                            message: message).call
      end
    end
  end
end
