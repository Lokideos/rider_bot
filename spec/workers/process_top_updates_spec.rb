# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HolyRider::Workers::ProcessTopUpdates do
  it { is_expected.to be_processed_in :trophies }
  it { is_expected.to be_retryable 5 }
  it { is_expected.to save_backtrace 20 }

  describe '#perform' do
    it 'should call :trophy_top_force_update on Player model' do
      expect(Player).to receive(:trophy_top_force_update)

      subject.perform
    end
  end
end
