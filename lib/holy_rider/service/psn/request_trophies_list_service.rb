# frozen_string_literal: true

module HolyRider
  module Service
    module PSN
      class RequestTrophiesListService
        def initialize(player_name:, token:, trophy_service_id:, extended: false, client: nil)
          @player_name = player_name
          @token = token
          @trophy_service_id = trophy_service_id
          @extended = extended
          @client = client || HolyRider::Client::PSN::Trophy::GameTrophyTitles
        end

        def call
          @client.new(player_name: @player_name, token: @token,
                      game_id: @trophy_service_id,
                      extended: @extended).request_trophy_list
        end
      end
    end
  end
end
