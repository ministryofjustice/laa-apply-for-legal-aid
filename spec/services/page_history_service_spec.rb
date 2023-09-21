require "rails_helper"

RSpec.describe PageHistoryService do
  subject { described_class.new(page_history_id:) }

  let!(:redis) { redis_config.new_client }
  let(:redis_config) { RedisClient.config(url: Rails.configuration.x.redis.page_history_url) }
  let(:page_history_id) { SecureRandom.uuid }
  let(:key) { "page_history:#{page_history_id}" }
  let(:page_history) { %w[page_1 page_2] }

  before { redis.call("FLUSHDB") }

  after { redis.call("QUIT") }

  describe "#write" do
    before { subject.write(page_history) }

    it "creates a history record with the correct key" do
      expect(redis.call("KEYS", "*")).to eq [key]
    end

    it "creates a history record with the correct value" do
      expect(redis.call("LRANGE", key, 0, -1)).to eq page_history
    end
  end

  describe "#read" do
    before { redis.call("RPUSH", key, page_history) }

    it "returns the correct history record" do
      expect(subject.read).to eq page_history
    end
  end
end
