require "rails_helper"

RSpec.describe LegalFramework::NonUkHomeAddresses::All, vcr: { cassette_name: "country_names_all", allow_playback_repeats: true } do
  subject(:instance) { described_class }

  let(:uri) { "#{Rails.configuration.x.legal_framework_api_host}/countries/all" }
  let(:clear_cache) { false }

  before { Redis.new(url: Rails.configuration.x.redis.lfa_url).flushdb if clear_cache }

  describe ".call" do
    subject(:call) { instance.call }

    context "when the cache is empty" do
      let(:clear_cache) { true }

      context "and the endpoint is called multiple times" do
        before do
          call
          call
        end

        it "makes a single external call" do
          expect(a_request(:get, uri)).to have_been_made.times(1)
        end
      end
    end

    it "returns the expected number of results" do
      expect(call.count).to eq 246
    end

    it "returns the expected collection of duck types" do
      results = call
      expect(results)
        .to all(respond_to(:code, :description))
    end
  end
end
