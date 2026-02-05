require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::NoNationalInsuranceNumbersStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_no_national_insurance_number_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(legal_aid_application) }

    it { is_expected.to eq :about_financial_means }

    it "sets the state machine" do
      forward_step
      expect(legal_aid_application.state_machine.type).to eq "NonPassportedStateMachine"
    end
  end
end
