# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessCommand
      include Sidekiq::Worker
      sidekiq_options queue: :commands, retry: 2, backtrace: 20

      def perform(chat_id, command, message_type)
        HolyRider::Service::CommandService.new(chat_id, command, message_type).call
      end
    end
  end
end
