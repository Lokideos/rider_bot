# frozen_string_literal: true

module HolyRider
  module Service
    module Watcher
      class AddHiddenTrophiesService
        TROPHY_TYPES = %w[platinum gold silver bronze].freeze

        def initialize(player_name:, hunter_name:)
          @redis = HolyRider::Application.instance.redis
          @player_name = player_name
          @player = Player.find(trophy_account: player_name)
          @token = @redis.get("holy_rider:trophy_hunter:#{hunter_name}:access_token")
          @user_trophies_client = HolyRider::Client::PSN::Trophy::UserTrophySummary
        end

        def call
          trophy_summary = @user_trophies_client.new(player_name: @player_name,
                                                     token: @token).request_trophy_list

          player = Player.find(trophy_account: @player_name)
          player.update(trophy_level: trophy_summary['level'],
                        level_up_progress: trophy_summary['progress'])
          initial_load = @redis.get("holy_rider:watcher:players:initial_load:#{player.trophy_account}:trophy_count")
          return if initial_load

          @player.delete_hidden_trophies

          TROPHY_TYPES.each do |trophy_type|
            instance_variable_set("@hidden_#{trophy_type}_trophies",
                                  trophy_summary['earnedTrophies'][trophy_type] -
                                    player.all_trophies_by_type(trophy_type).count)
          end

          TROPHY_TYPES.each do |trophy_type|
            trophy_type_count = instance_variable_get("@hidden_#{trophy_type}_trophies")
            save_hidden_trophies(player, trophy_type, trophy_type_count)
          end
        end

        private

        def save_hidden_trophies(player, trophy_type, count)
          count.times do
            player.add_trophy(Trophy.create(trophy_service_id: 0,
                                            trophy_name: 'hidden',
                                            trophy_description: 'hidden',
                                            trophy_type: trophy_type,
                                            trophy_icon_url: 'hidden',
                                            trophy_small_icon_url: 'hidden',
                                            trophy_earned_rate: 'hidden',
                                            trophy_rare: 3,
                                            hidden: true))
          end
        end
      end
    end
  end
end
