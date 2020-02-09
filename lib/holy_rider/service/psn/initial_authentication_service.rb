# frozen_string_literal: true

module HolyRider
  module Service
    module PSN
      class InitialAuthenticationService
        def initialize(trophy_hunter, sso_cookie, grant_code_client: nil, oauth_client: nil)
          @trophy_hunter = trophy_hunter
          @sso_cookie = sso_cookie
          @grant_code_client = grant_code_client ||
                               HolyRider::Client::PSN::Auth::GrantCode.new(trophy_hunter)
          @oauth_client = oauth_client ||
                          HolyRider::Client::PSN::Auth::RefreshToken.new(trophy_hunter)
        end

        # TODO: probably should create upper level auth object and encapsulate this logic there
        def call
          grant_code = @grant_code_client.request_grant_code(@sso_cookie)
          refresh_token = @oauth_client.request_refresh_token(grant_code)
          @trophy_hunter.update(refresh_token: refresh_token)
          HolyRider::Service::PSN::UpdateAccessTokenService.new(@trophy_hunter).call
        end
      end
    end
  end
end
