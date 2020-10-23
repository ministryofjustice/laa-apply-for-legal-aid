require 'rails_helper'

RSpec.describe OauthSessionSaver do
  let(:session) do
    {
      'session_id' => 'c38047b5f6a12c9de1540621ac8dc7d3',
      'current_application_id' => '583496de-f14e-46b5-bbff-8f95b4d6af22',
      'page_history_id' => 'c121c57a-2802-4793-b700-af30b212d63b',
      'warden.user.applicant.key' => [['50b98c1b-cf5d-428e-b32c-d20e9d1184dd'], nil],
      '_csrf_token' => 'bHisWZcUID4DqymnSBSyJ31OghMf8cop4Aw/9RJ3T9c=',
      'provider_id' => 'mock',
      'omniauth.state' => '6ab2a928a9ac79ff38ad32f73c47db3fce9a0a8f5d069a76'
    }
  end
  let(:key) { SecureRandom.uuid }
  let(:redis) { Redis.new(url: Rails.configuration.x.redis.oauth_session_url) }

  describe '.store' do
    it 'stores the session in the redis database as JSON' do
      OauthSessionSaver.store(key, session)
      stored_session = redis.get(key)
      expect(stored_session).to eq session.to_json
    end

    it 'remaining time-to-live is less than the services TTL value' do
      OauthSessionSaver.store(key, session)
      expect(redis.ttl(key) <= OauthSessionSaver::TIME_TO_LIVE_IN_SECONDS).to be true
    end
  end

  describe '.get' do
    context 'a record with the key exists' do
      before { redis.set(key, session.to_json) }
      it 'returns the reconstituted session hash' do
        expect(OauthSessionSaver.get(key)).to eq session
      end
    end

    context 'no such record exists' do
      it 'returns empty array' do
        expect(OauthSessionSaver.get(SecureRandom.uuid)).to eq({})
      end
    end
  end

  describe '.destroy!' do
    before { redis.set(key, session.to_json) }
    it 'deletes the record from the redis database' do
      OauthSessionSaver.destroy!(key)
      expect(redis.get(key)).to be_nil
    end
  end
end
