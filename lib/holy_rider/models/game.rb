# frozen_string_literal: true

class Game < Sequel::Model
  Game.plugin :timestamps, update_on_create: true
end
