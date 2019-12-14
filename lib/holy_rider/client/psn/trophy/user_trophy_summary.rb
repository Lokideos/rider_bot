# frozen_string_literal: true

module HolyRider
  module Client
    module PSN
      module Trophy
        class UserTrophySummary
          def initialize(player_name:, token:)
            @endpoint = "#{ENV['PROFILE_ENDPOINT']}/#{player_name}/profile2"
            @player_name = player_name
            @token = token
            @fields = 'trophySummary(@default,progress,earnedTrophies)'
          end

          def request_trophy_list
            response = Typhoeus::Request.new(
              url,
              method: :get,
              headers: headers
            ).run

            if response.response_code == 429
              sleep_increment = 0
              until response.response_code != 429
                p 'Watcher: gateway timeout - too many requests'
                sleep_increment += 1
                sleep(sleep_increment)
                response = Typhoeus::Request.new(
                  url,
                  method: :get,
                  headers: headers
                ).run
              end
            end

            Oj.load(response.response_body, {})['profile']['trophySummary']
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
              "fields=#{@fields}&"
          end
        end
      end
    end
  end
end
