# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class Help
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          player = Player.find(telegram_username: @command[@message_type]['from']['username'])
          message = ['Список команд:']
          message << '/find [game_title] поиск одной игры'
          message << '/games [game_title] поиск нескольких игр'
          message << '/top выводит топ по трофеям среди игроков'
          message << '/me выводит информацию о запросившем игроке'
          return [message.join("\n")] unless player.admin?

          message << '/hunter_stats - показывает текущих охотников за трофеями'
          message << '/hunter_credentials [hunter_name] - показывает email и пароль охотника'
          message << '/hunter_gear_up [ticket_id] [phone_code] - обновляет refresh token'
          message << '/hunter_gear_status [hunter_name] - отображает статус токена охотника'
          message << '/hunter_activate [hunter_name] - охотник начинает обращаться в PSN'
          message << '/hunter_deactivate [hunter_name] - охотник перестает обращаться в PSN'
          message << '/add_player [player_name] [*player_account] - добавляет игрока и ' \
                     'связывает его с PSN аккаунтом(опционально)'
          message << '/link_player [player_name] [player_account] - связывает игрока с PSN ' \
                     ' аккаунтом'

          [message.join("\n")]
        end
      end
    end
  end
end
