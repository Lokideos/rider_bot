# frozen_string_literal: true

module HolyRider
  module Service
    module PSN
      class RequestUpdatesService
        def initialize(player_name:, token:, client: nil)
          @player_name = player_name
          @token = token
          @client = client || HolyRider::Client::PSN::Trophy::AllTrophyTitles
        end

        def call
          @client.new(player_name: @player_name, token: @token).request_trophy_list
        end
      end
    end
  end
end
