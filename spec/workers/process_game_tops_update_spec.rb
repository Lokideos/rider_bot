# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HolyRider::Workers::ProcessGameTopsUpdate do
  it { is_expected.to be_processed_in :commands }
  it { is_expected.to be_retryable 2 }
  it { is_expected.to save_backtrace 20 }

  describe '#perform' do
    it 'should call :update_all_progress_caches on Game model' do
      expect(Game).to receive(:update_all_progress_caches)

      subject.perform
    end
  end
end
