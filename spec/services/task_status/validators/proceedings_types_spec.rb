require "rails_helper"
require_relative "task_status_validator_shared_examples"

RSpec.describe TaskStatus::Validators::ProceedingsTypes, :vcr do
  subject(:validator) { described_class.new(application) }

  let(:application) { create(:application) }
  let(:proceeding_one) do
    create(:proceeding, :da001, legal_aid_application: application,
                                client_involvement_type_ccms_code:,
                                client_involvement_type_description:,
                                used_delegated_functions:,
                                used_delegated_functions_on:,
                                accepted_emergency_defaults:,
                                emergency_level_of_service:,
                                emergency_level_of_service_name:,
                                emergency_level_of_service_stage:)
  end

  let(:proceeding_two) do
    create(:proceeding, :se014, legal_aid_application: application,
                                client_involvement_type_ccms_code: "A",
                                client_involvement_type_description: "Applicant/claimant/petitioner",
                                used_delegated_functions: true,
                                used_delegated_functions_on: 5.days.ago,
                                accepted_emergency_defaults: Time.zone.today,
                                emergency_level_of_service:,
                                emergency_level_of_service_name:,
                                emergency_level_of_service_stage:)
  end

  let(:client_involvement_type_ccms_code) { "A" }
  let(:client_involvement_type_description) { "Applicant/claimant/petitioner" }
  let(:used_delegated_functions) { true }
  let(:used_delegated_functions_on) { 5.days.ago }
  let(:accepted_emergency_defaults) { Time.zone.today }
  let(:emergency_level_of_service) { "3" }
  let(:emergency_level_of_service_name) { "Full Representation" }
  let(:emergency_level_of_service_stage) { "8" }

  it_behaves_like "a task status validator"

  describe "#valid?" do
    context "when there are no proceedings" do
      it { is_expected.not_to be_valid }
    end

    context "with proceedings" do
      before do
        proceeding_one
        proceeding_two
      end

      context "when client involvement type has not been answered for each proceeding" do
        let(:client_involvement_type_ccms_code) { nil }
        let(:client_involvement_type_description) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when client involvement type has been answered for each proceeding" do
        it { is_expected.to be_valid }
      end

      context "when delegated functions question has not been answered for each proceeding" do
        let(:used_delegated_functions) { nil }
        let(:used_delegated_functions_on) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when delegated functions question has been answered for each proceeding" do
        it { is_expected.to be_valid }

        context "and emergency certificate is not used" do
          it { is_expected.to be_valid }
        end

        context "and emergency certificate is used" do
          context "and emergency application has not been answered for each proceeding" do
            let(:accepted_emergency_defaults) { nil }
            let(:emergency_level_of_service) { nil }
            let(:emergency_level_of_service_name) { nil }
            let(:emergency_level_of_service_stage) { nil }

            it { is_expected.not_to be_valid }
          end

          context "and emergency application has been answered for each proceeding" do
            it { is_expected.to be_valid }
          end
        end
      end
    end
  end
end
