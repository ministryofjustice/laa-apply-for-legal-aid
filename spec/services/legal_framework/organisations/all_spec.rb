require "rails_helper"

RSpec.describe LegalFramework::Organisations::All, vcr: { cassette_name: "lfa_organisations_all", allow_playback_repeats: true } do
  subject(:instance) { described_class }

  let(:uri) { "#{Rails.configuration.x.legal_framework_api_host}/organisation_searches/all" }

  describe ".call" do
    subject(:call) { instance.call }

    it "makes one external call" do
      call
      expect(a_request(:get, uri)).to have_been_made.times(1)
    end

    it "returns the expected number of results" do
      expect(call.count).to be >= 1196
    end

    it "returns expected collection of duck types" do
      results = call
      expect(results)
        .to all(respond_to(:name, :ccms_opponent_id, :ccms_type_code, :ccms_type_text))
    end
  end
end
