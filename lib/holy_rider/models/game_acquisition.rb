# frozen_string_literal: true

class GameAcquisition < Sequel::Model
  many_to_one :player
  many_to_one :game
end
