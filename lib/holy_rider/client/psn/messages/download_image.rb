# frozen_string_literal: true

module HolyRider
  module Client
    module PSN
      module Messages
        class DownloadImage
          def initialize(image_url:, token:)
            @image_url = image_url
            @token = token
          end

          def get_image_data
            response = Typhoeus::Request.new(@image_url, method: :get, headers: headers).run
            response.body
          end

          private

          def headers
            {
              'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) ' \
                'AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
              'Authorization' => "Bearer #{@token}"
            }
          end
        end
      end
    end
  end
end
