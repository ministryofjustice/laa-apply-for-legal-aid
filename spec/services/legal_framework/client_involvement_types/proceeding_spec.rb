require "rails_helper"

RSpec.describe LegalFramework::ClientInvolvementTypes::Proceeding, vcr: { cassette_name: "lfa_client_involvement_types_proceeding" } do
  let(:uri) { "#{Rails.configuration.x.legal_framework_api_host}/client_involvement_types" }
  let(:proceeding) { "DA001" }
  let(:age) { nil }

  describe ".call" do
    subject(:call) { described_class.call(proceeding, age) }

    before { call }

    it "makes one external call" do
      expect(a_request(:post, uri)).to have_been_made.times(1)
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

    def full_list
      [
        "Applicant, claimant or petitioner",
        "Defendant or respondent",
        "A child subject of the proceeding",
        "Intervenor",
        "Joined party",
      ]
    end

    context "when age is provided" do
      context "when the applicant is < 18" do
        let(:age) { 17 }

        it "makes one external call", vcr: { cassette_name: "lfa_client_involvement_types_proceeding_under_18" } do
          expect(a_request(:post, uri)).to have_been_made.times(1)
        end

        it "returns the expected number of results" do
          expect(call.count).to eq 5
        end

        it "returns the expected values" do
          expect(call.map(&:description)).to eq full_list
        end
      end

      context "when the applicant is >= 18", vcr: { cassette_name: "lfa_client_involvement_types_proceeding_over_18" } do
        let(:age) { 18 }

        it "makes one external call" do
          expect(a_request(:post, uri)).to have_been_made.times(1)
        end

        it "returns the expected number of results" do
          expect(call.count).to eq 4
        end

        it "returns the expected values" do
          expect(call.map(&:description)).to eq filtered_list
        end

        def filtered_list
          [
            "Applicant, claimant or petitioner",
            "Defendant or respondent",
            "Intervenor",
            "Joined party",
          ]
        end
      end
    end
  end
end
