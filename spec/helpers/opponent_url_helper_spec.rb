require "rails_helper"

RSpec.describe OpponentUrlHelper do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:individual_opponent) { create(:opponent, :for_individual, legal_aid_application:) }
  let(:organisation_opponent) { create(:opponent, :for_organisation, legal_aid_application:) }

  describe ".opponent_url" do
    context "when opponent has type Individual" do
      it "returns the path for an individual opponent" do
        url = opponent_url("Individual", legal_aid_application, individual_opponent)
        expect(url).to eq "/providers/applications/#{legal_aid_application.id}/opponent_individuals/#{individual_opponent.id}?locale=en"
      end
    end

    context "when opponent has type Organisation" do
      it "returns the path for an organisation opponent" do
        url = opponent_url("Organisation", legal_aid_application, organisation_opponent)
        expect(url).to eq "/providers/applications/#{legal_aid_application.id}/opponent_organisations/#{organisation_opponent.id}?locale=en"
      end
    end

    context "when called with unexpected values" do
      it "raises an error" do
        expect { opponent_url("Fake") }.to raise_error "type Fake not supported"
      end
    end
  end
end
