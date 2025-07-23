require "rails_helper"

RSpec.describe TaskStatus::DWPOutcome do
  describe "#call" do
    subject(:task_status) { described_class.new(application).call }

    let(:application) { create(:application, :with_complete_applicant, confirm_dwp_result:) }
    let(:confirm_dwp_result) { nil }

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

      context "when confirm_dwp_result is nil" do
        it { is_expected.to be_not_started }
      end

      context "when confirm_dwp_result is false" do
        let(:confirm_dwp_result) { false }

        it { is_expected.to be_in_progress }
      end

      context "when confirm_dwp_result is true" do
        let(:confirm_dwp_result) { true }

        it { is_expected.to be_completed }
      end
    end
  end
end
