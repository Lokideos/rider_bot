# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessImageUpload
      include Sidekiq::Worker
      sidekiq_options queue: :screenshots, retry: 5, backtrace: 20

      def perform(filename)
        filepath = Application.root.concat("/tmp/screenshots/#{filename}")

        HolyRider::Service::Bot::UploadImageService
          .new(filepath: filepath).call

        HolyRider::Workers::ProcessFileDeletion.perform_async(filepath)
      end
    end
  end
end
