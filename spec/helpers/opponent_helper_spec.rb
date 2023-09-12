require "rails_helper"

RSpec.describe OpponentHelper do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:individual_opponent) { create(:opponent, :for_individual, legal_aid_application:) }
  let(:organisation_opponent) { create(:opponent, :for_organisation, legal_aid_application:, organisation_name: "Mid Beds Council", organisation_ccms_type_code: "LA", organisation_ccms_type_text: "Local Authority") }

  describe ".opponent_url" do
    subject(:url) { opponent_url(legal_aid_application, opponent) }

    context "when opponent is Individual" do
      let(:opponent) { individual_opponent }

      it "returns the path for an individual opponent" do
        expect(url).to eq "/providers/applications/#{legal_aid_application.id}/opponent_individuals/#{individual_opponent.id}?locale=en"
      end
    end

    context "when opponent is Organisation" do
      let(:opponent) { organisation_opponent }

      context "with no ccms_opponent_id (i.e. new organisation)" do
        before { opponent.ccms_opponent_id = nil }

        it "returns the path for a new organisation opponent" do
          expect(url).to eq "/providers/applications/#{legal_aid_application.id}/opponent_new_organisations/#{organisation_opponent.id}?locale=en"
        end
      end

      context "with ccms_opponent_id (i.e. existing organisation)" do
        before { opponent.ccms_opponent_id = 222_222 }

        it { expect(url).to be_nil }
      end
    end

    context "when called with unexpected values" do
      let(:opponent) { "NotAnOpponent" }

      it "returns nil" do
        expect(url).to be_nil
      end
    end
  end

  describe ".opponent_type_description" do
    subject(:type_description) { opponent_type_description(opponent) }

    context "when opponent is Individual" do
      let(:opponent) { individual_opponent }

      it "returns \"Individual\"" do
        expect(type_description).to eq "Individual"
      end
    end

    context "when opponent is Organisation" do
      let(:opponent) { organisation_opponent }

      it "returns the organisation type description" do
        expect(type_description).to eq "Local Authority"
      end
    end

    context "when opponent is unexpected" do
      let(:opponent) { "NotAnOpponent" }

      it "does not raise error" do
        expect { type_description }.not_to raise_error
      end

      it "returns fallback text" do
        expect(type_description).to eq "Unknown opponent type"
      end
    end
  end
end
