require "rails_helper"

RSpec.describe PageHistoryService do
  subject { described_class.new(page_history_id:) }

  let!(:redis) { Redis.new(url: Rails.configuration.x.redis.page_history_url) }
  let(:page_history_id) { SecureRandom.uuid }
  let(:key) { "page_history:#{page_history_id}" }
  let(:page_history) { %w[page_1 page_2] }

  before { redis.flushdb }

  after { redis.quit }

  describe "#write" do
    before { subject.write(page_history) }

    it "creates a history record with the correct key" do
      expect(redis.keys).to eq [key]
    end

    it "creates a history record with the correct value" do
      expect(JSON.parse(redis.get(key))).to eq page_history
    end
  end

  describe "#read" do
    before { redis.set(key, page_history) }

    it "returns the correct history record" do
      expect(JSON.parse(subject.read)).to eq page_history
    end
  end
end
