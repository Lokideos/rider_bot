# frozen_string_literal: true

class Trophy < Sequel::Model
  Trophy.plugin :timestamps, update_on_create: true

  one_to_many :trophy_acquisitions
  many_to_one :game
  many_to_many :players, left_key: :trophy_id, right_key: :player_id,
                         join_table: :trophy_acquisitions
end
