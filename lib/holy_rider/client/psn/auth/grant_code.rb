# frozen_string_literal: true

module HolyRider
  module Client
    module PSN
      module Auth
        class GrantCode
          def initialize(trophy_hunter)
            @url = ENV['CODE_URL']
            @state = trophy_hunter.state
            @duid = trophy_hunter.duid
            @app_context = trophy_hunter.app_context
            @client_id = trophy_hunter.client_id
            @scope = trophy_hunter.scope
            @response_type = 'code'
          end

          def request_grant_code(sso_cookie)
            response = Typhoeus::Request.new(
              "#{@url}?#{encoded_params}",
              method: :get,
              headers: headers(sso_cookie)
            ).run

            response.response_headers.scan(/X-NP-GRANT-CODE.*/).first.split(':').last.strip
          end

          private

          def headers(sso_cookie)
            {
              'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) ' \
                'AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
              'Cookie' => "npsso=#{sso_cookie}"
            }
          end

          def encoded_params
            URI.encode_www_form(
              'state': @state,
              'duid': @duid,
              'app_context': @app_context,
              'client_id': @client_id,
              'scope': @scope,
              'response_type': @response_type
            )
          end
        end
      end
    end
  end
end
