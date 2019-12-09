# frozen_string_literal: true

class Player < Sequel::Model
  Player.plugin :timestamps, update_on_create: true

  TROPHIES_WEIGHT = {
    bronze: 15,
    silver: 30,
    gold: 90,
    platinum: 180
  }.freeze

  one_to_many :game_acquisitions
  one_to_many :trophy_acquisitions
  many_to_many :games, left_key: :player_id, right_key: :game_id, join_table: :game_acquisitions
  many_to_many :trophies, left_key: :player_id, right_key: :trophy_id,
                          join_table: :trophy_acquisitions

  dataset_module do
    def active_trophy_accounts
      where(on_watch: true).map(:trophy_account)
    end
  end

  def self.trophy_top
    Player.all.map do |player|
      name = player.trophy_account
      points = player.trophies.map do |trophy|
        TROPHIES_WEIGHT[trophy.trophy_type.to_sym]
      end.inject(0, :+)

      {
        name: name,
        points: points
      }
    end
  end

  def admin?
    admin
  end

  def on_watch?
    on_watch
  end
end
