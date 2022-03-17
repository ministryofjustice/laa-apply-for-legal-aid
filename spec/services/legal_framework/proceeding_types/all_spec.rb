require "rails_helper"

RSpec.describe LegalFramework::ProceedingTypes::All, :vcr do
  subject(:all) { described_class }
  let(:uri) { "#{Rails.configuration.x.legal_framework_api_host}/proceeding_types/all" }

  describe ".call" do
    subject(:call) { all.call }
    before { call }

    it "makes one external call" do
      expect(a_request(:get, uri)).to have_been_made.times(1)
    end

    it "returns the expected number of results" do
      expect(call.count).to eq 12
    end
  end
end
