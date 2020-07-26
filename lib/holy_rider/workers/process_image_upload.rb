# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessImageUpload
      include Sidekiq::Worker
      sidekiq_options queue: :screenshots, retry: 5, backtrace: 20

      def perform(player_name, filename)
        filepath = Application.root.concat("/screenshots/#{filename}")

        HolyRider::Service::Bot::UploadImageService
          .new(player_name: player_name, filepath: filepath).call

        HolyRider::Workers::ProcessFileDeletion.perform_async(filepath)
      end
    end
  end
end
