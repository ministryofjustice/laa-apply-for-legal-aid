require "rails_helper"

RSpec.describe LegalFramework::OrganisationTypes::All, :vcr do
  subject(:all) { described_class }

  let(:uri) { "#{Rails.configuration.x.legal_framework_api_host}/organisation_types/all" }

  describe ".call" do
    subject(:call) { all.call }

    before { call }

    it "makes one external call" do
      expect(a_request(:get, uri)).to have_been_made.times(1)
    end

    it "returns the expected number of results" do
      expect(call.count).to eq 14
    end
  end
end
