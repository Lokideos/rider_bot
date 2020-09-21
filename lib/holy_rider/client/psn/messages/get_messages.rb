# frozen_string_literal: true

module HolyRider
  module Client
    module PSN
      module Messages
        class GetMessages
          REQUEST_FIELDS = 'threadMembers,threadNameDetail,threadThumbnailDetail,threadProperty,' \
            'latestTakedownEventDetail,newArrivalEventDetail,threadEvents'

          def initialize(thread_id:, token:, message_count: 10)
            @thread_id = thread_id
            @token = token
            @message_count = message_count
            @endpoint = ENV['GET_MESSAGES_ENDPOINT']
          end

          def request_message_list
            response = Typhoeus::Request.new(url, method: :get, headers: headers).run
            Oj.load(response.response_body, {})['threadEvents']
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
            "#{@endpoint}/#{@thread_id}?" \
              "count=#{@message_count}&" \
              "fields=#{REQUEST_FIELDS}"
          end
        end
      end
    end
  end
end
