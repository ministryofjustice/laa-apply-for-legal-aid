require "rails_helper"

RSpec.describe TaskStatus::EmploymentIncomes do
  subject(:instance) { described_class.new(application) }

  let(:application) { create(:legal_aid_application, applicant:) }
  let(:applicant) { create(:applicant, employed:, extra_employment_information:) }
  let(:employed) { nil }
  let(:extra_employment_information) { nil }

  describe "#call" do
    subject(:status) { instance.call }

    context "when employment status is not yet completed" do
      before { applicant.update!(employed: nil) }

      it { is_expected.to be_not_started }
    end

    context "when employment status is completed" do
      let(:employed) { true }

      context "when employment income is incomplete" do
        it { is_expected.to be_in_progress }
      end

      context "when employment income is complete" do
        let(:extra_employment_information) { false }

        it { is_expected.to be_completed }
      end
    end
  end
end
