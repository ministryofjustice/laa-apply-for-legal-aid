require "rails_helper"

RSpec.describe TaskStatus::DWPOutcome do
  describe "#call", :vcr do
    subject(:task_status) { described_class.new(application, status_results).call }

    let(:application) { create(:application, linked_application_completed: true, dwp_result_confirmed:, dwp_override:) }
    let(:dwp_override) { nil }
    let(:dwp_result_confirmed) { nil }

    let(:status_results) { { CheckProviderAnswers => TaskStatus::ValueObject.new.completed! } }

    context "when check_your_answers is not completed" do
      let(:status_results) { { TaskStatus::CheckProviderAnswers => TaskStatus::ValueObject.new.in_progress! } }

      it { is_expected.to be_not_ready }
    end

    context "when check_your_answers is completed" do
      let(:status_results) { { TaskStatus::CheckProviderAnswers => TaskStatus::ValueObject.new.completed! } }

      context "when dwp_result_confirmed is nil" do
        it { is_expected.to be_not_started }
      end

      context "when dwp_result_confirmed is false" do
        let(:dwp_result_confirmed) { false }
        let(:dwp_override) { create(:dwp_override, :with_no_evidence) }

        it { is_expected.to be_in_progress }
      end

      context "when dwp_result_confirmed is true" do
        let(:dwp_result_confirmed) { true }

        it { is_expected.to be_completed }
      end

      context "when dwp_result_confirmed is false and the provider has overridden the dwp result" do
        let(:dwp_result_confirmed) { false }
        let(:dwp_override) { create(:dwp_override, :with_evidence) }

        it { is_expected.to be_completed }
      end
    end
  end
end
