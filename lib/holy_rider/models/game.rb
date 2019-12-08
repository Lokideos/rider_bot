# frozen_string_literal: true

class Game < Sequel::Model
  Game.plugin :timestamps, update_on_create: true

  one_to_many :game_acquisitions
  one_to_many :trophies
  many_to_many :players, left_key: :game_id, right_key: :player_id, join_table: :game_acquisitions

  dataset_module do
    def find_game(title)
      where(title: /^#{title}*/i)
        .left_join(:game_acquisitions, game_id: :id)
        .order(:last_updated_date)
        .reverse
        .limit(1)
        .first
    end

    def find_relevant_game(title)
      where(title: /.*#{title}*/i)
        .left_join(:game_acquisitions, game_id: :id)
        .order(:last_updated_date)
        .reverse
        .limit(1)
        .first
    end
  end

  def self.top_game(title)
    game = find_game(title) || find_relevant_game(title)
    return unless game

    game_id = game.values[:game_id]
    progresses = GameAcquisition.find_progresses(game_id)
    players_with_platinum = players_with_platinum_trophy(game_id)
    {
      game: game,
      progresses: progresses,
      platinum: players_with_platinum
    }
  end

  def self.players_with_platinum_trophy(game_id)
    find(id: game_id).trophies.find { |trophy| trophy.trophy_type == 'platinum' }&.players
  end
end
