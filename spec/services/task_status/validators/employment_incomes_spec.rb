require "rails_helper"
require_relative "task_status_validator_shared_examples"

RSpec.describe TaskStatus::Validators::EmploymentIncomes do
  subject(:validator) { described_class.new(application) }

  let(:application) { create(:legal_aid_application, applicant:) }
  let(:applicant) { create(:applicant, extra_employment_information:, extra_employment_information_details:) }
  let(:extra_employment_information) { nil }
  let(:extra_employment_information_details) { nil }

  describe "#valid?" do
    context "when extra_employment_information is nil" do
      it { is_expected.not_to be_valid }
    end

    context "when extra_employment_information is false" do
      let(:extra_employment_information) { false }

      it { is_expected.to be_valid }
    end

    context "when extra_employment_information is true" do
      let(:extra_employment_information) { true }

      context "when no extra_employment_information_details entered" do
        it { is_expected.not_to be_valid }
      end

      context "when extra_employment_information_details are entered" do
        let(:extra_employment_information_details) { "details" }

        it { is_expected.to be_valid }
      end
    end
  end
end
