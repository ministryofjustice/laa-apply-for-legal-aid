require "rails_helper"

RSpec.describe TaskStatus::DWPOutcome do
  describe "#call" do
    subject(:task_status) { described_class.new(application).call }

    let(:application) { create(:application, :with_complete_applicant, dwp_result_confirmed:) }
    let(:dwp_result_confirmed) { nil }

    context "when check_your_answers is not completed" do
      before do
        application.reviewed[:check_provider_answers] = { status: "in_progress", at: Time.current }
        application.save!
      end

      it { is_expected.to be_not_ready }
    end

    context "when check_your_answers is completed" do
      before do
        application.reviewed[:check_provider_answers] = { status: "completed", at: Time.current }
        application.save!
      end

      context "when dwp_result_confirmed is nil" do
        it { is_expected.to be_not_started }
      end

      context "when dwp_result_confirmed is false" do
        let(:dwp_result_confirmed) { false }

        it { is_expected.to be_in_progress }
      end

      context "when dwp_result_confirmed is true" do
        let(:dwp_result_confirmed) { true }

        it { is_expected.to be_completed }
      end
    end
  end
end
