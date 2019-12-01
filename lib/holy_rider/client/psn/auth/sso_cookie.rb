# frozen_string_literal: true

module HolyRider
  module Client
    module PSN
      module Auth
        class SsoCookie
          def initialize(trophy_hunter, ticket_uuid, code)
            @url = ENV['SSO_URL']
            @authentication_type = 'two_step'
            @client_id = trophy_hunter.client_id
            @ticket_uuid = ticket_uuid
            @code = code
          end

          def request_sso_cookie
            response = Typhoeus::Request.new(
              @url,
              method: :post,
              headers: headers,
              body: body
            ).run

            Oj.load(response.response_body, {})['npsso']
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
              'authentication_type': @authentication_type,
              'ticket_uuid': @ticket_uuid,
              'code': @code,
              'client_id': @client_id
            )
          end
        end
      end
    end
  end
end
