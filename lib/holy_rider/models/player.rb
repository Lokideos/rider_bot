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

    def last_updated_game_ids(trophy_account, service_ids)
      where(trophy_account: trophy_account)
        .inner_join(:game_acquisitions, player_id: :id)
        .inner_join(:games, id: :game_id)
        .where(trophy_service_id: service_ids)
        .map(:last_updated_date)
    end
  end

  def self.trophy_top
    Player.all.map do |player|
      name = player.trophy_account
      telegram_name = player.telegram_username
      points = player.trophy_points ? player.trophy_points.to_i : player.update_trophy_points
      {
        trophy_account: name,
        telegram_username: telegram_name,
        points: points
      }
    end.sort { |left_player, right_player| right_player[:points] <=> left_player[:points] }
  end

  def trophy_points
    redis = HolyRider::Application.instance.redis
    redis.get("holy_rider:players:#{trophy_account}:trophy_points")
  end

  def update_trophy_points
    redis = HolyRider::Application.instance.redis
    trophy_points = trophies.map do |trophy|
      TROPHIES_WEIGHT[trophy.trophy_type.to_sym]
    end.inject(0, :+)
    redis.set("holy_rider:players:#{trophy_account}:trophy_points", trophy_points)

    trophy_points
  end

  def admin?
    admin
  end

  def on_watch?
    on_watch
  end

  def trophies_by_type(trophy_type, hidden: false)
    trophies.select { |trophy| trophy.trophy_type == trophy_type && trophy.hidden == hidden }
  end

  def all_public_trophies
    trophies.select { |trophy| trophy.hidden == false }
  end

  def all_hidden_trophies
    trophies.select { |trophy| trophy.hidden == true }
  end

  def all_trophies_by_type(trophy_type)
    trophies.select { |trophy| trophy.trophy_type == trophy_type }
  end

  def profile
    {
      trophies: {
        bronze: trophies_by_type('bronze'),
        silver: trophies_by_type('silver'),
        gold: trophies_by_type('gold'),
        platinum: trophies_by_type('platinum'),
        total: all_public_trophies
      },
      hidden_trophies: {
        bronze: trophies_by_type('bronze', hidden: true),
        silver: trophies_by_type('silver', hidden: true),
        gold: trophies_by_type('gold', hidden: true),
        platinum: trophies_by_type('platinum', hidden: true),
        total: all_hidden_trophies
      },
      games: games,
      trophy_level: trophy_level,
      level_up_progress: level_up_progress
    }
  end
end
