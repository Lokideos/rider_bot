# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HolyRider::Workers::EnqueueTrophyRarityUpdates do
  let(:rarity_update_worker) { HolyRider::Workers::ProcessTrophyRarityUpdate }
  let(:top_update_worker) { HolyRider::Workers::ProcessTopUpdates }
  let(:game_id) { 'game_id' }
  let(:trophies_data) { %w[trophy_data_1 trophy_data_2] }

  it { is_expected.to be_processed_in :trophies }
  it { is_expected.to be_retryable 5 }
  it { is_expected.to save_backtrace 20 }

  describe '#perform' do
    it 'should enqueue ProcessTrophyRarityUpdate worker per each given trophy data' do
      trophies_data.each do |trophy_data|
        expect(rarity_update_worker).to receive(:perform_async).with(game_id, trophy_data)
      end

      subject.perform(game_id, trophies_data)
    end

    it 'should enqueue ProcessTopUpdate worker' do
      expect(top_update_worker).to receive(:perform_async)

      subject.perform(game_id, trophies_data)
    end
  end
end
