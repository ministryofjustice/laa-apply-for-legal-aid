require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapital::CheckCapitalAnswersStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_check_capital_answers_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :capital_income_assessment_results }
  end
end
