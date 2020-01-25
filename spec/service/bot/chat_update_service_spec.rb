# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HolyRider::Service::Bot::ChatUpdateService do
  let(:client_object) { double('non_default_client.new') }
  let(:telegram_client) { HolyRider::Client::Telegram }
  let(:telegram_client_object) { double('HolyRider::Client::Telegram.new') }

  before do
    allow(telegram_client).to receive(:new).and_return(telegram_client_object)
    allow(telegram_client_object).to receive(:get_updates).and_return('telegram_client_result')
    allow(client_object).to receive(:get_updates).and_return('client_result')
  end

  describe '#call' do
    context 'with default client' do
      it 'should call :get_updates method on client' do
        expect(telegram_client_object).to receive(:get_updates)

        subject.call
      end

      it 'should return result of :get_updates method' do
        expect(subject.call).to eq 'telegram_client_result'
      end
    end

    context 'with non default client' do
      subject { HolyRider::Service::Bot::ChatUpdateService.new(client: client_object) }

      it 'should call :get_updates method on client' do
        expect(client_object).to receive(:get_updates)

        subject.call
      end

      it 'should return result of :get_updates method' do
        expect(subject.call).to eq 'client_result'
      end
    end
  end
end
