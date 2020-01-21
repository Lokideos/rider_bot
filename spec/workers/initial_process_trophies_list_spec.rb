# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HolyRider::Workers::InitialProcessTrophiesList do
  let(:service) { HolyRider::Service::Watcher::ProcessTrophiesListService }
  let(:service_object) { double('HolyRider::Service::Watcher::ProcessTrophiesListService.new') }
  let(:player) { 'player_info' }
  let(:game) { 'game_info' }
  let(:trophy_service_id) { 'trophy_service_id' }
  let(:initial) { 'initial_flag' }

  it { is_expected.to be_processed_in :initial_user_data_load }
  it { is_expected.to be_retryable 5 }
  it { is_expected.to save_backtrace 20 }

  describe '#perform' do
    before do
      allow(service).to receive(:new).and_return(service_object)
      allow(service_object).to receive(:call)
    end

    it 'should create service object' do
      expect(service).to receive(:new).with(player, game, trophy_service_id, initial)

      subject.perform(player, game, trophy_service_id, initial)
    end

    it 'should call ProcessTrophiesListService service' do
      expect(service_object).to receive(:call)

      subject.perform(player, game, trophy_service_id, initial)
    end
  end
end
