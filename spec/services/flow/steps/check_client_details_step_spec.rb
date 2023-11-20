require "rails_helper"

RSpec.describe Flow::Steps::CheckClientDetailsStep do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject(:path) { described_class.path.call(legal_aid_application) }

    it "returns the check_client_details_path when called" do
      expect(path).to eq "/providers/applications/#{legal_aid_application.id}/check_client_details?locale=en"
    end
  end

  describe "#forward" do
    subject(:forward) { described_class.forward }

    it "returns the about_financial_means step when called" do
      expect(forward).to eq(:received_benefit_confirmations)
    end
  end

  describe "#check_answers" do
    subject(:check_answers) { described_class.check_answers }

    it "returns nil" do
      expect(check_answers).to be_nil
    end
  end
end
