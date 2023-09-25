require "rails_helper"

RSpec.describe OauthSessionSaver do
  let(:session) do
    {
      "session_id" => "c38047b5f6a12c9de1540621ac8dc7d3",
      "current_application_id" => "583496de-f14e-46b5-bbff-8f95b4d6af22",
      "page_history_id" => "c121c57a-2802-4793-b700-af30b212d63b",
      "warden.user.applicant.key" => "[[50b98c1b-cf5d-428e-b32c-d20e9d1184dd], nil]",
      "_csrf_token" => "bHisWZcUID4DqymnSBSyJ31OghMf8cop4Aw/9RJ3T9c=",
      "provider_id" => "mock",
      "omniauth.state" => "6ab2a928a9ac79ff38ad32f73c47db3fce9a0a8f5d069a76",
    } # TODO: investigate how to store warden.user.applicant.key as array with RedisClient hash
  end
  let(:key) { SecureRandom.uuid }
  let!(:redis) { redis_config.new_client }
  let(:redis_config) { RedisClient.config(url: Rails.configuration.x.redis.oauth_session_url) }

  describe ".store" do
    it "stores the session in the redis database as JSON" do
      described_class.store(key, session)
      stored_session = redis.call("HGETALL", key)
      expect(stored_session).to eq session
    end

    it "remaining time-to-live is less than the services TTL value" do
      described_class.store(key, session)
      expect(redis.call("TTL", key) <= OauthSessionSaver::TIME_TO_LIVE_IN_SECONDS).to be true
    end
  end

  describe ".get" do
    context "when a record with the key exists" do
      # before { redis.set(key, session.to_json) }
      before do
        session.each do |hm_key, value|
          redis.call("HMSET", key, hm_key, value.to_s)
        end
      end

      it "returns the reconstituted session hash" do
        expect(described_class.get(key)).to eq session
      end
    end

    context "when no such record exists" do
      it "returns empty array" do
        expect(described_class.get(SecureRandom.uuid)).to eq({})
      end
    end
  end

  describe ".destroy!" do
    # before { redis.set(key, session.to_json) }
    before do
      session.each do |hm_key, value|
        redis.call("HMSET", key, hm_key, value.to_s)
      end
    end

    it "deletes the record from the redis database" do
      described_class.destroy!(key)
      # expect(redis.get(key)).to be_nil
      expect(redis.call("HGETALL", key)).to eq({})
    end
  end
end
