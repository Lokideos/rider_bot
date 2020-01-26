# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HolyRider::Service::Bot::SendChatMessageService do
  let(:client_object) { double('non_default_client.new') }
  let(:telegram_client) { HolyRider::Client::Telegram }
  let(:telegram_client_object) { double('HolyRider::Client::Telegram.new') }
  let(:sending_message_result) { { 'result' => { 'message_id' => '1' } } }
  let(:correct_uid) do
    Digest::SHA2.new.hexdigest([chat_id, sending_message_result.dig('result', 'message_id')].join)
  end
  let(:correct_expiration_time) do
    HolyRider::Service::Bot::SendChatMessageService::DEFAULT_EXPIRATION_TIME
  end
  let(:chat_id) { 'chat_id' }
  let(:message) { 'message' }
  let(:redis) { HolyRider::Application.instance.redis }

  before do
    allow(telegram_client).to receive(:new).and_return(telegram_client_object)
    allow(telegram_client_object).to receive(:send_message).and_return(sending_message_result)
    allow(client_object).to receive(:send_message)
  end

  context 'with default client' do
    subject do
      HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id, message: message)
    end

    it 'should call :send_message with correct parameters' do
      expect(telegram_client_object).to receive(:send_message).with(chat_id: chat_id,
                                                                    message: message)

      subject.call
    end
  end

  context 'with custom client' do
    subject do
      HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                          message: message,
                                                          client: client_object)
    end

    it 'should call :send_message with correct parameters' do
      expect(client_object).to receive(:send_message).with(chat_id: chat_id, message: message)

      subject.call
    end
  end

  context 'with set up @to_delete flag' do
    subject do
      HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                          message: message,
                                                          to_delete: true)
    end

    it 'should add correct message uid to redis holy_rider:bot:messages:to_delete set' do
      subject.call

      expect(redis.smembers('holy_rider:bot:messages:to_delete')).to include(correct_uid)
    end

    it 'should set holy_rider:bot:messages:to_delete:expiration:uid key with correct value' do
      subject.call

      expect(
        redis.get("holy_rider:bot:messages:to_delete:expiration:#{correct_uid}")
      ).to eq 'present'
    end

    it 'should set holy_rider:bot:messages:to_delete:expiration:uid key with correct expire' do
      subject.call

      expect(
        redis.ttl("holy_rider:bot:messages:to_delete:expiration:#{correct_uid}")
      ).to eq correct_expiration_time
    end

    it 'should set holy_rider:bot:messages:to_delete:info:uid key with correct value' do
      correct_value = {
        'chat_id' => chat_id,
        'message_id' => sending_message_result.dig('result', 'message_id')
      }
      subject.call

      expect(redis.hgetall("holy_rider:bot:messages:to_delete:info:#{correct_uid}")).to eq correct_value
    end
  end

  context 'without set up @to_delete flag' do
    subject do
      HolyRider::Service::Bot::SendChatMessageService.new(chat_id: chat_id,
                                                          message: message)
    end

    it 'should return message' do
      expect(subject.call).to eq sending_message_result
    end

    it 'should not add message uid to redis holy_rider:bot:messages:to_delete set' do
      subject.call

      expect(redis.smembers('holy_rider:bot:messages:to_delete')).to_not include(correct_uid)
    end

    it 'should not set holy_rider:bot:messages:to_delete:expiration:uid key with correct value' do
      subject.call

      expect(
        redis.get("holy_rider:bot:messages:to_delete:expiration:#{correct_uid}")
      ).to be_nil
    end

    it 'should not set holy_rider:bot:messages:to_delete:info:uid key with correct value' do
      expect(redis.hgetall("holy_rider:bot:messages:to_delete:info:#{correct_uid}")).to be_empty
    end
  end
end
