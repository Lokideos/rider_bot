# frozen_string_literal: true

class Game < Sequel::Model
  Game.plugin :timestamps, update_on_create: true

  one_to_many :game_acquisitions
  many_to_many :players, left_key: :game_id, right_key: :player_id, join_table: :game_acquisitions
end
