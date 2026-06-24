require "rails_helper"

RSpec.describe LegalFramework::ClientInvolvementTypes::Proceeding, vcr: { cassette_name: "lfa_client_involvement_types_proceeding" } do
  let(:uri) { "#{Rails.configuration.x.legal_framework_api_host}/client_involvement_types/#{proceeding}" }
  let(:proceeding) { "DA001" }
  let(:clear_cache) { false }

  describe ".call" do
    subject(:call) { described_class.call(proceeding) }

    before do
      Redis.new(url: Rails.configuration.x.redis.lfa_url).flushdb if clear_cache
      call
    end

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
      expect(call.count).to eq 5
    end

    it "returns the expected values" do
      expect(call.map(&:description)).to eq full_list
    end

    def full_list
      [
        "Applicant, claimant or petitioner",
        "Defendant or respondent",
        "A child subject of the proceeding",
        "Intervenor",
        "Joined party",
      ]
    end
  end
end
