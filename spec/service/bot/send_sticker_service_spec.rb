# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HolyRider::Service::Bot::SendStickerService do
  let(:client_object) { double('non_default_client.new') }
  let(:telegram_client) { HolyRider::Client::Telegram }
  let(:telegram_client_object) { double('HolyRider::Client::Telegram.new') }
  let(:chat_id) { 'chat_id' }
  let(:sticker) { 'sticker' }

  before do
    allow(telegram_client).to receive(:new).and_return(telegram_client_object)
    allow(telegram_client_object).to receive(:send_sticker)
    allow(client_object).to receive(:send_sticker)
  end

  context 'with default client' do
    subject { HolyRider::Service::Bot::SendStickerService.new(chat_id: chat_id, sticker: sticker) }

    it 'should call :send_sticker with correct parameters' do
      expect(telegram_client_object).to receive(:send_sticker).with(chat_id: chat_id,
                                                                    sticker: sticker)

      subject.call
    end
  end

  context 'with custom client' do
    subject do
      HolyRider::Service::Bot::SendStickerService.new(chat_id: chat_id,
                                                      sticker: sticker,
                                                      client: client_object)
    end

    it 'should call :send_sticker with correct parameters' do
      expect(client_object).to receive(:send_sticker).with(chat_id: chat_id,
                                                           sticker: sticker)

      subject.call
    end
  end
end
