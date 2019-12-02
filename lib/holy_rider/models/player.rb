# frozen_string_literal: true

class Player < Sequel::Model
  Player.plugin :timestamps, update_on_create: true

  def admin?
    admin
  end

  def on_watch?
    on_watch
  end
end
