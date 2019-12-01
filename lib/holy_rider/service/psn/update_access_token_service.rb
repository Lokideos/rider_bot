# frozen_string_literal: true

module HolyRider
  module Service
    module PSN
      class UpdateAccessTokenService
        def initialize(trophy_hunter, client: nil)
          @trophy_hunter = trophy_hunter
          @client = client || HolyRider::Client::PSN::Auth::AccessToken.new(trophy_hunter)
        end

        def call
          access_token = @client.request_token
          @trophy_hunter.store_access_token(access_token)
          access_token
        end
      end
    end
  end
end
