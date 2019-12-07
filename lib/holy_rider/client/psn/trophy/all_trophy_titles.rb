# frozen_string_literal: true

module HolyRider
  module Client
    module PSN
      module Trophy
        class AllTrophyTitles
          def initialize(player_name:, token:, icon_size: 'm', offset: 0, limit: 10)
            @endpoint = ENV['ALL_TROPHY_TITLES_ENDPOINT']
            @player_name = player_name
            @token = token
            @icon_size = icon_size
            @offset = offset
            @limit = limit
            redis = HolyRider::Application.instance.redis
            @initial = redis.get("holy_rider:watcher:players:initial_load:#{player_name}")
            @limit = 128 if @initial
          end

          def request_trophy_list
            response = Typhoeus::Request.new(url, method: :get, headers: headers).run
            parsed_response = Oj.load(response.response_body, {})
            return parsed_response unless @initial

            until (parsed_response['totalResults'] - @limit - @offset).negative?
              @offset += @limit
              next_response = Typhoeus::Request.new(url, method: :get, headers: headers).run
              next_parsed_response = Oj.load(next_response.response_body, {})
              parsed_response['trophyTitles'] << next_parsed_response['trophyTitles']
            end
            parsed_response['trophyTitles'] = parsed_response['trophyTitles'].flatten

            parsed_response
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
              "offset=#{@offset}&" \
              "limit=#{@limit}&" \
              "comparedUser=#{@player_name}"
          end
        end
      end
    end
  end
end
