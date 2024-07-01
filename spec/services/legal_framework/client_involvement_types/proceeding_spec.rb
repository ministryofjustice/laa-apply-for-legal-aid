require "rails_helper"

RSpec.describe LegalFramework::ClientInvolvementTypes::Proceeding, vcr: { cassette_name: "lfa_client_involvement_types_proceeding" } do
  let(:uri) { "#{Rails.configuration.x.legal_framework_api_host}/client_involvement_types/#{proceeding}" }
  let(:proceeding) { "DA001" }

  describe ".call" do
    subject(:call) { described_class.call(proceeding) }

    before { call }

    it "makes one external call" do
      expect(a_request(:get, uri)).to have_been_made.times(1)
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
