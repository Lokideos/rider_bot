# frozen_string_literal: true

module HolyRider
  module Client
    module PSN
      module Trophy
        class GameTrophyTitles
          EXTENDED_FIELDS = %w[trophyRare trophyEarnedRate trophySmallIconUrl groupId].freeze

          def initialize(player_name:, token:, game_id:, extended: false)
            @endpoint = "#{ENV['GAME_TROPHY_TITLES_ENDPOINT']}/#{game_id}/trophyGroups/all/trophies"
            @player_name = player_name
            @token = token
            @fields = extended ? "@default,#{EXTENDED_FIELDS.join(',')}" : '@default'
          end

          def request_trophy_list
            response = Typhoeus::Request.new(
              url,
              method: :get,
              headers: headers
            ).run

            Oj.load(response.response_body, {})['trophies']
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
              "fields=#{@fields}&" \
              'visibleType=1&' \
              'npLanguage=en&' \
              "comparedUser=#{@player_name}"
          end
        end
      end
    end
  end
end
