require "rails_helper"

RSpec.describe Flow::Steps::Partner::UnexpectedEmploymentIncomeStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_partners_unexpected_employment_income_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :partner_receives_state_benefits }
  end
end
