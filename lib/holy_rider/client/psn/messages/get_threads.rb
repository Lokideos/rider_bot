# frozen_string_literal: true

module HolyRider
  module Client
    module PSN
      module Messages
        class GetThreads
          DEFAULT_FIELDS = %w[threadMembers threadNameDetail threadThumbnailDetail threadProperty
                              latestMessageEventDetail latestTakedownEventDetail
                              newArrivalEventDetail].freeze

          def initialize(token, limit: 10, offset: 0)
            @token = token
            @limit = limit
            @offset = offset
            @endpoint = ENV['GET_THREADS_ENDPOINT']
          end

          def request_threads_list
            response = Typhoeus::Request.new(url, method: :get, headers: headers).run
            Oj.load(response.response_body, {})['threads']
          end

          private

          def headers
            {
              'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) ' \
                'AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
              'Authorization' => "Bearer #{@token}"
            }
          end

          def url
            "#{@endpoint}?" \
              "fields=#{DEFAULT_FIELDS.join(',')}&" \
              "limit=#{@limit}&" \
              "offset=#{@offset}"
          end
        end
      end
    end
  end
end
