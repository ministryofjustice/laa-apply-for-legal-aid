require "rails_helper"

RSpec.describe BankHolidayStore do
  subject(:instance) { described_class.new }

  let(:redis) { Redis.new(url: Rails.configuration.x.redis.bank_holidays_url) }
  let(:redis_key) { "bank_holiday_dates" }
  let(:date_values) { %w[2025-12-25 2025-12-26] }

  before do
    redis.flushdb
  end

  # Prevent leaking of redis data that will not be cleared up unless you do it here.
  after do
    redis.flushdb
    redis.quit
  end

  describe ".write" do
    it "behaves the same as #write" do
      expect {
        described_class.write(date_values)
      }.to change { redis.get(redis_key) }.from(nil).to(date_values.to_json)
    end
  end

  describe ".read" do
    it "behaves the same as #read" do
      redis.set(redis_key, date_values.to_json)
      expect(described_class.read).to eq(date_values)
    end
  end

  describe ".destroy!" do
    it "behaves the same as #destroy!" do
      redis.set(redis_key, date_values.to_json)

      expect {
        described_class.destroy!
      }.to change { redis.get(redis_key) }.from(date_values.to_json).to(nil)
    end
  end

  describe "#write" do
    it "writes date values to Redis" do
      expect {
        instance.write(date_values)
      }.to change { redis.get(redis_key) }.from(nil).to(date_values.to_json)
    end
  end

  describe "#read" do
    context "when cache hit" do
      it "reads date values from Redis" do
        redis.set(redis_key, date_values.to_json)
        expect(instance.read).to eq(date_values)
      end
    end

    context "when cache miss and fallback enabled" do
      before do
        allow(BankHolidayRetriever).to receive(:dates).and_return(date_values)
        instance.destroy!
      end

      it "fetches latest dates from API and writes to cache" do
        expect {
          instance.read
        }.to change { redis.get(redis_key) }.from(nil).to(date_values.to_json)
      end

      it "returns latest dates from API" do
        expect(instance.read).to eq(date_values)
      end

      it "logs info message on cache miss" do
        expect(Rails.logger).to receive(:info).with(/BankHolidayStore cache miss, fetching latest data from API/)
        instance.read
      end

      context "when API returns no dates" do
        let(:date_values) { nil }

        it "logs fetch error, alerts on it, and returns empty array" do
          expect(Rails.logger).to receive(:error).with(/BankHolidayStore read error:.*cache miss, fetching latest data from API returned no dates/)
          expect(Sentry).to receive(:capture_message).with(/BankHolidayStore read error:.*cache miss, fetching latest data from API returned no dates/)
          expect(instance.read).to eq([])
        end
      end
    end

    context "when cache miss and fallback disabled" do
      before do
        allow(redis).to receive(:get).with(redis_key).and_return(nil)
        instance.destroy!
      end

      it "logs type error, alerts on it, and returns empty array" do
        expect(Rails.logger).to receive(:error).with(/BankHolidayStore read error: no implicit conversion of nil into String/)
        expect(Sentry).to receive(:capture_message).with(/BankHolidayStore read error: no implicit conversion of nil into String/)
        expect(instance.read(fallback_to_api_for_cache_miss: false)).to eq([])
      end
    end
  end

  describe "#destroy!" do
    it "deletes the Redis key" do
      redis.set(redis_key, date_values.to_json)

      expect {
        instance.destroy!
      }.to change { redis.get(redis_key) }.from(date_values.to_json).to(nil)
    end
  end
end
