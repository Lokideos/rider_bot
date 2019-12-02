# frozen_string_literal: true

module HolyRider
  module Client
    module PSN
      module Trophy
        class AllTrophyTitles
          def initialize(player_name:, token:, icon_size: 'm', limit: 10)
            @endpoint = ENV['ALL_TROPHY_TITLES_ENDPOINT']
            @player_name = player_name
            @token = token
            @icon_size = icon_size
            @limit = limit
          end

          def request_trophy_list
            response = Typhoeus::Request.new(
              url,
              method: :get,
              headers: headers
            ).run

            Oj.load(response.response_body, {})
          end

          private

          def headers
            {
              'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) ' \
                'AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
              'Authorization': "Bearer #{@token}"
            }
          end

          def url
            "#{@endpoint}?" \
              'fields=@default&' \
              'npLanguage=en&' \
              "iconSize=#{@icon_size}&" \
              'platform=PS3,PSVITA,PS4&' \
              'offset=0&' \
              "limit=#{@limit}&" \
              "comparedUser=#{@player_name}"
          end
        end
      end
    end
  end
end
