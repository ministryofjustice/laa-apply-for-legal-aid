require "rails_helper"
require_relative "task_status_validator_shared_examples"

RSpec.describe TaskStatus::Validators::ProceedingsTypes, :vcr do
  subject(:validator) { described_class.new(application) }

  let(:application) { create(:application) }
  let(:proceeding_one) do
    create(:proceeding, legal_aid_application: application,
                        ccms_code: "DA001",
                        meaning: "Inherent jurisdiction high court injunction",
                        description: "to be represented on an application for an injunction, order or declaration under the inherent jurisdiction of the court.",
                        substantive_cost_limitation: 25_000,
                        delegated_functions_cost_limitation: rand(1...1_000_000.0).round(2),
                        name: "inherent_jurisdiction_high_court_injunction",
                        matter_type: "Domestic Abuse",
                        category_of_law: "Family",
                        category_law_code: "MAT",
                        ccms_matter_code: "MINJN",
                        client_involvement_type_ccms_code:,
                        client_involvement_type_description:,
                        used_delegated_functions:,
                        used_delegated_functions_on:,
                        accepted_emergency_defaults:,
                        accepted_substantive_defaults:,
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
                                accepted_emergency_defaults: true,
                                accepted_substantive_defaults: true,
                                emergency_level_of_service:,
                                emergency_level_of_service_name:,
                                emergency_level_of_service_stage:)
  end

  let(:emergency_final_hearing) do
    create(:final_hearing, proceeding: proceeding_one,
                           work_type: :emergency,
                           listed: emergency_final_hearing_listed,
                           date: emergency_final_hearing_date,
                           details: emergency_final_hearing_details)
  end
  let(:substantive_final_hearing) { create(:final_hearing, proceeding: proceeding_one, work_type: :substantive, listed: true, date: 2.days.ago) }
  let(:scope_limitation) { create(:scope_limitation, :emergency, proceeding: proceeding_one) }
  let(:client_involvement_type_ccms_code) { "A" }
  let(:client_involvement_type_description) { "Applicant/claimant/petitioner" }
  let(:used_delegated_functions) { true }
  let(:used_delegated_functions_on) { 5.days.ago }
  let(:accepted_emergency_defaults) { true }
  let(:accepted_substantive_defaults) { true }
  let(:emergency_level_of_service) { "3" }
  let(:emergency_level_of_service_name) { "Full Representation" }
  let(:emergency_level_of_service_stage) { "8" }
  let(:emergency_final_hearing_date) { 2.days.ago }
  let(:emergency_final_hearing_listed) { true }
  let(:emergency_final_hearing_details) { "Reason for not listing" }

  it_behaves_like "a task status validator"

  describe "#valid?" do
    context "when there are no proceedings" do
      it { is_expected.not_to be_valid }
    end

    context "with proceedings" do
      before do
        proceeding_one
        proceeding_two
        scope_limitation
        substantive_final_hearing
        emergency_final_hearing

        create(:final_hearing, proceeding: proceeding_two, work_type: :substantive, listed: true)
        create(:final_hearing, proceeding: proceeding_two, work_type: :emergency, listed: true)
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
          context "and emergency default question has not been answered for each proceeding" do
            let(:accepted_emergency_defaults) { nil }

            it { is_expected.not_to be_valid }
          end

          context "and emergency defaults question has been answered for each proceeding and is false" do
            let(:accepted_emergency_defaults) { false }

            context "and the emergency level of service has not been answered for each proceeding" do
              let(:emergency_level_of_service) { nil }

              it { is_expected.not_to be_valid }
            end

            context "and emergency level of service has been answered for each proceeding" do
              context "and emergency level of service is family help (higher)" do
                let(:emergency_level_of_service) { "1" }
                let(:emergency_level_of_service_name) { "Family Help (Higher)" }

                it { is_expected.to be_valid }

                context "and the emergency scope limitations have been answered for each proceeding" do
                  it { is_expected.to be_valid }
                end

                context "and the emergency scope limitations have not been answered for each proceeding" do
                  let(:scope_limitation) { nil }

                  it { is_expected.not_to be_valid }
                end
              end

              context "and emergency level of service is full representation" do
                let(:emergency_level_of_service) { "3" }
                let(:emergency_level_of_service_name) { "Full Representation" }

                it { is_expected.to be_valid }

                context "and final hearing has not been chosen for each proceeding" do
                  let(:emergency_final_hearing) { nil }

                  it { is_expected.not_to be_valid }
                end

                context "and final hearing is listed" do
                  context "with a hearing date" do
                    it { is_expected.to be_valid }
                  end

                  context "without a hearing date" do
                    let(:emergency_final_hearing_date) { nil }

                    it { is_expected.not_to be_valid }
                  end
                end

                context "and final hearing is not listed" do
                  let(:emergency_final_hearing_listed) { false }

                  context "with a reason" do
                    it { is_expected.to be_valid }
                  end

                  context "without a reason" do
                    let(:emergency_final_hearing_details) { nil }

                    it { is_expected.not_to be_valid }
                  end
                end
              end
            end
          end
        end

        context "and substantive default question has not been answered for each proceeding" do
          let(:accepted_substantive_defaults) { nil }

          it { is_expected.not_to be_valid }
        end

        context "and substantive defaults question has been answered for each proceeding and is false" do
          let(:accepted_substantive_defaults) { false }

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
