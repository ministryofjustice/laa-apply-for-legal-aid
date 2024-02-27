require "rails_helper"

RSpec.describe LegalFramework::NonUkCorrespondenceAddresses::All, vcr: { cassette_name: "country_names_all", allow_playback_repeats: true } do
  subject(:instance) { described_class }

  let(:uri) { "#{Rails.configuration.x.legal_framework_api_host}/countries/all" }

  describe ".call" do
    subject(:call) { instance.call }

    it "makes one external call" do
      call
      expect(a_request(:get, uri)).to have_been_made.times(1)
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
