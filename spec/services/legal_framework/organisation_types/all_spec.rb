require "rails_helper"

RSpec.describe LegalFramework::OrganisationTypes::All, :vcr do
  subject(:all) { described_class }

  let(:uri) { "#{Rails.configuration.x.legal_framework_api_host}/organisation_types/all" }
  let(:clear_cache) { false }

  before { Redis.new(url: Rails.configuration.x.redis.lfa_url).flushdb if clear_cache }

  describe ".call" do
    subject(:call) { all.call }

    before { call }

    context "when the cache is empty" do
      let(:clear_cache) { true }

      context "and the endpoint is called multiple times" do
        before { call }

        it "makes a single external call" do
          expect(a_request(:get, uri)).to have_been_made.times(1)
        end
      end
    end

    it "returns the expected number of results" do
      expect(call.count).to eq 14
    end
  end
end
