# frozen_string_literal: true

module HolyRider
  module Service
    module Watcher
      class AddHiddenTrophiesService
        TROPHY_TYPES = %w[platinum gold silver bronze].freeze

        def initialize(player_name:, hunter_name:)
          @player_name = player_name
          @token = @redis.get("holy_rider:trophy_hunter:#{hunter_name}:access_token")
          @user_trophies_client = HolyRider::Client::PSN::Trophy::UserTrophySummary
        end

        def call
          trophy_summary = @user_trophies_client.new(player_name: @player_name,
                                                     token: @token).request_trophy_list

          player = Player.find(trophy_account: @player_name)
          player.update(trophy_level: trophy_summary['level'],
                        level_up_progress: trophy_summary['progress'])
          initial_load = @redis.get("holy_rider:watcher:players:initial_load:#{@player.trophy_account}:trophy_count")
          return if initial_load

          hidden_platinum_trophies = trophy_summary['earnedTrophies']['platinum'] -
                                     player.trophies_by_type('platinum').count
          hidden_gold_trophies = trophy_summary['earnedTrophies']['gold'] +
                                 player.trophies_by_type('gold').count
          hidden_silver_trophies = trophy_summary['earnedTrophies']['silver'] +
                                   player.trophies_by_type('silver').count
          hidden_bronze_trophies = trophy_summary['earnedTrophies']['bronze'] +
                                   player.trophies_by_type('bronze').count -
                                   TROPHY_TYPES.each do |trophy_type|
                                     trophy_type_count = Kernel.const_get("hidden_#{trophy_type}_trophies")
                                     save_hidden_trophies(trophy_type, trophy_type_count)
                                   end
        end

        private

        def save_hidden_trophies(trophy_type, count)
          count.times do
            Player.add_trophy(Trophy.create(trophy_service_id: 0,
                                            trophy_name: 'hidden',
                                            trophy_description: 'hidden',
                                            trophy_type: trophy_type,
                                            trophy_icon_url: 'hidden',
                                            trophy_earned_rate: 'hidden',
                                            trophy_rare: 3,
                                            hidden: false))
          end
        end
      end
    end
  end
end
