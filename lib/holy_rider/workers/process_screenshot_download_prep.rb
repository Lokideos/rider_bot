# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessScreenshotDownloadPrep
      include Sidekiq::Worker
      sidekiq_options queue: :screenshots, retry: 5, backtrace: 20

      def perform(message_thread, token)
        HolyRider::Service::Screenshots::ProcessMessagesService
          .new(message_thread: message_thread, token: token).call
      end
    end
  end
end
