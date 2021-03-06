# frozen_string_literal: true

module HolyRider
  module Service
    module Screenshots
      class DownloadScreenshotService
        def initialize(message:, token:, sender_name:, client: nil)
          @message = message
          @token = token
          @sender_name = sender_name
          @client = client || HolyRider::Client::PSN::Messages::DownloadImage
        end

        def call
          image_url = @message['messageEventDetail']['attachedMediaPath']
          image_data = @client.new(image_url: image_url, token: @token).get_image_data
          return if image_data.nil?

          FileUtils.mkdir('screenshots') unless Dir.exist? 'screenshots'

          filename = "#{SecureRandom.uuid}.jpeg"
          File.write("screenshots/#{filename}", image_data)

          HolyRider::Workers::ProcessImageUpload.perform_async(@sender_name, filename)
        end
      end
    end
  end
end
