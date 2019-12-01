# frozen_string_literal: true

module HolyRider
  module Client
    module PSN
      module Auth
        class AccessToken
          def initialize(trophy_hunter)
            @url = ENV['OAUTH_URL']
            @app_context = trophy_hunter.app_context
            @client_id = trophy_hunter.client_id
            @client_secret = trophy_hunter.client_secret
            @refresh_token = trophy_hunter.refresh_token
            @duid = trophy_hunter.duid
            @grant_type = 'refresh_token'
            @scope = trophy_hunter.scope
          end

          def request_token
            response = Typhoeus::Request.new(
              @url,
              method: :post,
              headers: headers,
              body: body
            ).run

            Oj.load(response.response_body, {})['access_token']
          end

          private

          def headers
            {
              'Content-Type': 'application/x-www-form-urlencoded',
              'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) ' \
                'AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
            }
          end

          def body
            URI.encode_www_form(
              'app_context': @app_context,
              'client_id': @client_id,
              'client_secret': @client_secret,
              'refresh_token': @refresh_token,
              'duid': @duid,
              'grant_type': @grant_type,
              'scope': @scope
            )
          end
        end
      end
    end
  end
end
