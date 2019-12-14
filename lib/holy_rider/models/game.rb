# frozen_string_literal: true

class Game < Sequel::Model
  Game.plugin :timestamps, update_on_create: true

  GAME_CACHE_EXPIRE = 120

  one_to_many :game_acquisitions
  one_to_many :trophies
  many_to_many :players, left_key: :game_id, right_key: :player_id, join_table: :game_acquisitions

  dataset_module do
    # TODO: try to combine datasets
    def find_game(title, platform: nil)
      unless platform
        return where(title: title)
               .left_join(:game_acquisitions, game_id: :id)
               .order(:last_updated_date)
               .reverse
               .limit(1)
               .first
      end

      where(title: title, platform: platform)
        .left_join(:game_acquisitions, game_id: :id)
        .order(:last_updated_date)
        .reverse
        .limit(1)
        .first
    end

    def find_exact_game(title, platform)
      where(title: title, platform: platform)
        .left_join(:game_acquisitions, game_id: :id)
        .limit(1)
        .first
    end

    def find_games(title, limit: 10)
      where(title: title)
        .left_join(:game_acquisitions, game_id: :id)
        .order(:last_updated_date)
        .reverse
        .limit(limit)
        .map { |record| record.title + " #{record.platform}" }
    end
  end

  def self.relevant_games(title, message, message_type)
    return unless title.length > 1

    first_games = find_games(/^#{title}.*/i).uniq
    second_games = []
    query_size = first_games.size
    second_games = find_games(/.*#{title}.*/i, limit: 10 - query_size).uniq if query_size < 10

    player = message[message_type]['from']['username']
    redis = HolyRider::Application.instance.redis
    all_games = (first_games << second_games).flatten.uniq
    all_games.each_with_index do |game_title, index|
      redis.setex("holy_rider:top:#{player}:games:#{index + 1}", GAME_CACHE_EXPIRE, game_title)
      redis.sadd("holy_rider:top:#{player}:games", "holy_rider:top:#{player}:games:#{index + 1}")
    end

    all_games
  end

  def self.find_game_from_cache(player, index)
    redis = HolyRider::Application.instance.redis
    game = redis.get("holy_rider:top:#{player}:games:#{index}")
    return unless game

    game_title = game.split(' ')[0..-2].join(' ')
    game_platform = game.split(' ').last
    redis.smembers("holy_rider:top:#{player}:games").each do |key|
      redis.del(key)
    end
    redis.del("holy_rider:top:#{player}:games")
    top_game(game_title, platform: game_platform, exact: true) if game_title
  end

  # TODO: refactoring needed
  def self.top_game(title, platform: nil, exact: false)
    return unless title.length > 1

    game = if exact
             find_exact_game(title, platform)
           else
             find_game(/^#{title}.*/i, platform: platform) ||
               find_game(/.*#{title}.*/i, platform: platform)
           end
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
