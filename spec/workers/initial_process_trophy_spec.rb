# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HolyRider::Workers::InitialProcessTrophy do
  let(:service) { HolyRider::Service::Watcher::SaveTrophyService }
  let(:service_object) { double('HolyRider::Service::Watcher::SaveTrophyService.new') }
  let(:player_id) { 'player_id' }
  let(:trophy_id) { 'trophy_id' }
  let(:trophy_earning_time) { 'trophy_earning_time' }
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
      expect(service).to receive(:new).with(player_id, trophy_id, trophy_earning_time, initial)

      subject.perform(player_id, trophy_id, trophy_earning_time, initial)
    end

    it 'should call SaveTrophyService service' do
      expect(service_object).to receive(:call)

      subject.perform(player_id, trophy_id, trophy_earning_time, initial)
    end
  end
end
