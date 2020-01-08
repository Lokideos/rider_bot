# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessMessageDeletion
      include Sidekiq::Worker
      sidekiq_options queue: :message_deletion, retry: 5, backtrace: 20

      def perform(message_uid)
        HolyRider::Service::Bot::DeleteMessageService.new(message_uid: message_uid).call
      end
    end
  end
end
