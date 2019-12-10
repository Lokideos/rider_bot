# frozen_string_literal: true

require_relative 'command/help'
require_relative 'command/hunter_credentials'
require_relative 'command/hunter_stats'
require_relative 'command/hunter_gear_status'
require_relative 'command/hunter_gear_up'
require_relative 'command/hunter_activate'
require_relative 'command/hunter_deactivate'
require_relative 'command/add_player'
require_relative 'command/link_player'
require_relative 'command/list_players'
require_relative 'command/find'
require_relative 'command/games'
require_relative 'command/top'
require_relative 'command/me'
require_relative 'command/get_game_from_cache'

module HolyRider
  module Service
    class CommandService
      CACHED_GAMES = (1..10).to_a.map(&:to_s).freeze

      ADMIN_COMMANDS = %w[
        hunter_credentials
        hunter_stats
        hunter_gear_status
        hunter_gear_up
        hunter_activate
        hunter_deactivate
        add_player
        link_player
        list_players
      ].freeze

      COMMON_COMMANDS = %w[
        find
        games
        top
        me
      ].concat(CACHED_GAMES).freeze

      META_COMMANDS = %w[help].freeze

      def initialize(command, message_type)
        @admin_chat_id = ENV['ADMIN_CHAT_ID']
        @ps_chat_id = ENV['PS_CHAT_ID']
        @current_chat_id = command[message_type]['chat']['id']
        @command = command
        @message_type = message_type
      end

      def call
        return unless Player.find(telegram_username: @command[@message_type]['from']['username'])

        command = @command[@message_type]['text'].split(' ').first[1..-1]
        return unless [COMMON_COMMANDS, ADMIN_COMMANDS, META_COMMANDS].flatten.include? command

        command = 'get_game_from_cache' if CACHED_GAMES.include? command
        messages = Kernel.const_get(
          "HolyRider::Service::Command::#{prepared_command(command)}"
        ).new(@command,
              @message_type).call
        chat_id = ADMIN_COMMANDS.include?(command) ? @admin_chat_id : @ps_chat_id
        chat_id = @current_chat_id if META_COMMANDS.include? command

        messages&.each do |message|
          HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                              message: message).call
        end
      end

      private

      def prepared_command(command)
        command.split('_').map(&:capitalize).join
      end
    end
  end
end
