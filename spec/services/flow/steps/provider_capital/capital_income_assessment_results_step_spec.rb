require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapital::CapitalIncomeAssessmentResultsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, copy_case:) }
  let(:copy_case) { true }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_capital_income_assessment_result_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when the application has been copied from another application" do
      it { is_expected.to eq :check_merits_answers }
    end

    context "when no vehicles remain on the application" do
      let(:copy_case) { false }

      it { is_expected.to eq :merits_task_lists }
    end
  end
end
