require "rails_helper"
require_relative "task_status_validator_shared_examples"

RSpec.describe TaskStatus::Validators::EmploymentIncomes do
  subject(:validator) { described_class.new(application) }

  describe "#valid?" do
    context "when hmrc returns details of a single employment" do
      # Validating with # Validating with Applicants::EmploymentIncomeForm.rb
      let(:application) { create(:legal_aid_application, applicant:) }
      let(:applicant) { create(:applicant, extra_employment_information:, extra_employment_information_details:) }
      let(:extra_employment_information) { nil }
      let(:extra_employment_information_details) { nil }

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

    context "when hmrc returns unexpected employment details" do
      # Validating with Applicants::UnexpectedEmploymentIncomeForm.rb
      let(:application) { create(:legal_aid_application, applicant:) }
      let(:applicant) { create(:applicant, extra_employment_information_details:) }
      let(:extra_employment_information_details) { nil }

      context "when extra_employment_information_details are nil" do
        it { is_expected.not_to be_valid }
      end

      context "when extra_employment_information_details are entered" do
        let(:extra_employment_information_details) { "details" }

        it { is_expected.to be_valid }
      end
    end

    context "when hmrc returns no employment details" do
      # Validating with LegalAidApplications::FullEmploymentDetailsForm.rb
      let(:application) { create(:legal_aid_application, full_employment_details:, applicant:) }
      let(:applicant) { create(:applicant) }
      let(:full_employment_details) { nil }

      context "when full_employment_details is nil" do
        it { is_expected.not_to be_valid }
      end

      context "when full_employment_details are entered" do
        let(:full_employment_details) { "details" }

        it { is_expected.to be_valid }
      end
    end
  end
end
