require "rails_helper"
require_relative "task_status_validator_shared_examples"

RSpec.describe TaskStatus::Validators::ProceedingsTypes, :vcr do
  subject(:validator) { described_class.new(application) }

  let(:application) do
    create(:application, emergency_cost_override:,
                         emergency_cost_reasons:,
                         emergency_cost_requested:,
                         substantive_cost_override:,
                         substantive_cost_reasons:,
                         substantive_cost_requested:)
  end

  let(:emergency_cost_override) { true }
  let(:emergency_cost_reasons) { "Reasons" }
  let(:emergency_cost_requested) { 5_000 }
  let(:substantive_cost_override) { true }
  let(:substantive_cost_reasons) { "Reasons" }
  let(:substantive_cost_requested) { 25_000 }

  let(:proceeding_one) do
    create(:proceeding, legal_aid_application: application,
                        ccms_code: "DA001",
                        meaning: "Inherent jurisdiction high court injunction",
                        description: "to be represented on an application for an injunction, order or declaration under the inherent jurisdiction of the court.",
                        substantive_cost_limitation:,
                        delegated_functions_cost_limitation:,
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
                        substantive_level_of_service:,
                        emergency_level_of_service_name:,
                        emergency_level_of_service_stage:)
  end

  let(:proceeding_two) do
    create(:proceeding, :se014, legal_aid_application: application,
                                substantive_cost_limitation:,
                                client_involvement_type_ccms_code: "A",
                                client_involvement_type_description: "Applicant/claimant/petitioner",
                                used_delegated_functions: proceeding_two_used_delegated_functions,
                                used_delegated_functions_on: proceeding_two_used_delegated_functions_on,
                                accepted_emergency_defaults: proceeding_two_accepted_emergency_defaults,
                                accepted_substantive_defaults: proceeding_two_accepted_substantive_defaults,
                                emergency_level_of_service: proceeding_two_emergency_level_of_service,
                                substantive_level_of_service: proceeding_two_substantive_level_of_service,
                                emergency_level_of_service_name: "Full Representation",
                                emergency_level_of_service_stage: "8",
                                no_scope_limitations: true)
  end

  let(:proceeding_two_used_delegated_functions) { true }
  let(:proceeding_two_used_delegated_functions_on) { 5.days.ago }
  let(:proceeding_two_accepted_emergency_defaults) { true }
  let(:proceeding_two_accepted_substantive_defaults) { true }
  let(:proceeding_two_emergency_level_of_service) { "3" }
  let(:proceeding_two_substantive_level_of_service) { "3" }

  let(:emergency_final_hearing_proceeding) { proceeding_one }
  let(:substantive_final_hearing_proceeding) { proceeding_one }
  let(:emergency_scope_limitation_proceeding) { proceeding_one }
  let(:substantive_scope_limitation_proceeding) { proceeding_one }

  let(:emergency_final_hearing) do
    create(:final_hearing, proceeding: emergency_final_hearing_proceeding,
                           work_type: :emergency,
                           listed: emergency_final_hearing_listed,
                           date: emergency_final_hearing_date,
                           details: emergency_final_hearing_details)
  end

  let(:substantive_final_hearing) do
    create(:final_hearing, proceeding: substantive_final_hearing_proceeding,
                           work_type: :substantive,
                           listed: substantive_final_hearing_listed,
                           date: substantive_final_hearing_date,
                           details: substantive_final_hearing_details)
  end

  let(:emergency_scope_limitation) { create(:scope_limitation, :emergency, proceeding: emergency_scope_limitation_proceeding) }
  let(:substantive_scope_limitation) { create(:scope_limitation, :substantive, proceeding: substantive_scope_limitation_proceeding) }
  let(:client_involvement_type_ccms_code) { "A" }
  let(:client_involvement_type_description) { "Applicant/claimant/petitioner" }
  let(:used_delegated_functions) { true }
  let(:used_delegated_functions_on) { 5.days.ago }
  let(:accepted_emergency_defaults) { true }
  let(:accepted_substantive_defaults) { true }
  let(:emergency_level_of_service) { "3" }
  let(:substantive_level_of_service) { "3" }
  let(:emergency_level_of_service_name) { "Full Representation" }
  let(:emergency_level_of_service_stage) { "8" }
  let(:emergency_final_hearing_date) { 2.days.ago }
  let(:emergency_final_hearing_listed) { true }
  let(:emergency_final_hearing_details) { "Reason for not listing" }
  let(:substantive_final_hearing_date) { 2.days.ago }
  let(:substantive_final_hearing_listed) { true }
  let(:substantive_final_hearing_details) { "Reason for not listing" }
  let(:substantive_cost_limitation) { 25_000 }
  let(:delegated_functions_cost_limitation) { 2_250 }

  it_behaves_like "a task status validator"

  describe "#valid?" do
    context "when there are no proceedings" do
      it { is_expected.not_to be_valid }
    end

    context "with proceedings" do
      before do
        proceeding_one
        proceeding_two
        emergency_scope_limitation
        substantive_scope_limitation
        substantive_final_hearing
        emergency_final_hearing
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
        let(:used_delegated_functions) { true }
        let(:used_delegated_functions_on) { 5.days.ago }

        context "and emergency defaults not accepted for each proceeding" do
          let(:accepted_emergency_defaults) { false }

          it { is_expected.to be_valid }
        end

        context "and emergency defaults accepted for each proceeding" do
          let(:accepted_emergency_defaults) { true }

          it { is_expected.to be_valid }
        end

        context "and emergency defaults question not answered for each proceeding" do
          let(:accepted_emergency_defaults) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when emergency defaults not accepted for each proceeding" do
          let(:accepted_emergency_defaults) { false }

          context "and the emergency level of service has not been answered for each proceeding" do
            let(:emergency_level_of_service) { nil }

            it { is_expected.not_to be_valid }
          end

          context "and the emergency level of service has been answered for each proceeding" do
            let(:emergency_level_of_service) { "3" }

            it { is_expected.to be_valid }
          end

          context "when proceeding two uses emergency family help (higher)" do
            let(:accepted_emergency_defaults) { true }
            let(:proceeding_two_accepted_emergency_defaults) { false }
            let(:proceeding_two_emergency_level_of_service) { "1" }

            context "and the emergency scope limitations have been answered for proceeding two" do
              let(:emergency_scope_limitation) { create(:scope_limitation, :emergency, proceeding: proceeding_two) }

              it { is_expected.to be_valid }
            end

            context "and the emergency scope limitations have not been answered for proceeding two" do
              let(:emergency_scope_limitation) { nil }

              it { is_expected.not_to be_valid }
            end
          end

          context "when emergency level of service is full representation" do
            let(:emergency_level_of_service) { "3" }
            let(:emergency_level_of_service_name) { "Full Representation" }

            it "does not require a final hearing when only one level of service is available" do
              expect(validator).to be_valid
            end
          end

          context "when proceeding two reaches emergency full representation" do
            let(:accepted_emergency_defaults) { true }
            let(:proceeding_two_accepted_emergency_defaults) { false }
            let(:emergency_scope_limitation_proceeding) { proceeding_two }

            context "and final hearing has not been chosen for proceeding two" do
              let(:emergency_final_hearing) { nil }

              it { is_expected.not_to be_valid }
            end

            context "and final hearing is listed for proceeding two" do
              let(:emergency_final_hearing_proceeding) { proceeding_two }

              context "with a hearing date" do
                let(:emergency_final_hearing_date) { 2.days.ago }

                it { is_expected.to be_valid }
              end

              context "without a hearing date" do
                let(:emergency_final_hearing_date) { nil }

                it { is_expected.not_to be_valid }
              end
            end

            context "and final hearing is not listed for proceeding two" do
              let(:emergency_final_hearing_proceeding) { proceeding_two }
              let(:emergency_final_hearing_listed) { false }

              context "with a reason" do
                let(:emergency_final_hearing_details) { "Some reason" }

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

      context "when accepted substantive default question has not been answered for each proceeding" do
        let(:accepted_substantive_defaults) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when accepted substantive default question has been answered for each proceeding and is false" do
        let(:accepted_substantive_defaults) { false }

        it { is_expected.to be_valid }

        context "and the substantive level of service has not been answered for each proceeding" do
          let(:substantive_level_of_service) { nil }

          it { is_expected.not_to be_valid }
        end

        context "and substantive level of service has been answered for each proceeding" do
          context "when proceeding two uses substantive family help (higher)" do
            let(:accepted_substantive_defaults) { true }
            let(:proceeding_two_accepted_substantive_defaults) { false }
            let(:proceeding_two_substantive_level_of_service) { "1" }
            let(:substantive_scope_limitation_proceeding) { proceeding_two }

            it { is_expected.to be_valid }

            context "and the substantive scope limitations have not been answered for proceeding two" do
              let(:substantive_scope_limitation) { nil }

              it { is_expected.not_to be_valid }
            end
          end

          context "and substantive level of service is full representation" do
            let(:substantive_level_of_service) { "3" }
            let(:substantive_level_of_service_name) { "Full Representation" }

            it "does not require a final hearing when only one level of service is available" do
              expect(validator).to be_valid
            end
          end

          context "when proceeding two reaches substantive full representation" do
            let(:accepted_substantive_defaults) { true }
            let(:proceeding_two_accepted_substantive_defaults) { false }
            let(:substantive_scope_limitation_proceeding) { proceeding_two }

            context "and final hearing has not been chosen for proceeding two" do
              let(:substantive_final_hearing) { nil }

              it { is_expected.not_to be_valid }
            end

            context "and final hearing is listed for proceeding two" do
              let(:substantive_final_hearing_proceeding) { proceeding_two }

              context "with a hearing date" do
                it { is_expected.to be_valid }
              end

              context "without a hearing date" do
                let(:substantive_final_hearing_date) { nil }

                it { is_expected.not_to be_valid }
              end
            end

            context "and final hearing is not listed for proceeding two" do
              let(:substantive_final_hearing_proceeding) { proceeding_two }
              let(:substantive_final_hearing_listed) { false }

              context "with a reason" do
                it { is_expected.to be_valid }
              end

              context "without a reason" do
                let(:substantive_final_hearing_details) { nil }

                it { is_expected.not_to be_valid }
              end
            end
          end
        end
      end

      context "when emergency cost is overridable" do
        let(:delegated_functions_cost_limitation) { 5_000 }

        context "and emergency cost override form has been answered yes for each proceeding" do
          let(:emergency_cost_override) { true }
          let(:emergency_cost_reasons) { "some reason" }
          let(:emergency_cost_requested) { 5_000 }

          it { is_expected.to be_valid }
        end

        context "and emergency cost override form has been answered no for each proceeding" do
          let(:emergency_cost_override) { false }
          let(:emergency_cost_reasons) { nil }
          let(:emergency_cost_requested) { nil }

          it { is_expected.to be_valid }
        end

        context "and emergency cost override form has not been answered for each proceeding" do
          let(:emergency_cost_override) { nil }
          let(:emergency_cost_reasons) { nil }
          let(:emergency_cost_requested) { nil }

          it { is_expected.not_to be_valid }
        end
      end

      context "when substantive cost is overridable" do
        let(:substantive_cost_limitation) { 15_000 }

        context "and substantive cost override form has been answered yes for each proceeding" do
          let(:substantive_cost_override) { true }
          let(:substantive_cost_reasons) { "Some reason" }
          let(:substantive_cost_requested) { 5_000 }

          it { is_expected.to be_valid }
        end

        context "and substantive cost override form has been answered no for each proceeding" do
          let(:substantive_cost_override) { false }
          let(:substantive_cost_reasons) { nil }
          let(:substantive_cost_requested) { nil }

          it { is_expected.to be_valid }
        end

        context "and substantive cost override form has not been answered for each proceeding" do
          let(:substantive_cost_override) { nil }
          let(:substantive_cost_reasons) { nil }
          let(:substantive_cost_requested) { nil }

          it { is_expected.not_to be_valid }
        end
      end

      context "with an emergency scope limitation that requires a hearing date" do
        let(:application) do
          create(:application,
                 emergency_cost_override: false,
                 substantive_cost_override: false)
        end

        let(:proceeding_one) do
          create(:proceeding, :se013,
                 legal_aid_application: application,
                 client_involvement_type_ccms_code: "A",
                 client_involvement_type_description: "Applicant/claimant/petitioner",
                 used_delegated_functions: true,
                 used_delegated_functions_on: 5.days.ago,
                 accepted_emergency_defaults: false,
                 accepted_substantive_defaults: true,
                 emergency_level_of_service: "1",
                 emergency_level_of_service_name: "Family Help (Higher)",
                 no_scope_limitations: true)
        end

        let(:emergency_scope_limitation) do
          create(:scope_limitation,
                 proceeding: proceeding_one,
                 scope_type: :emergency,
                 code: "CV027",
                 meaning: "Hearing/Adjournment",
                 description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                 hearing_date: emergency_hearing_date)
        end

        before do
          proceeding_one
          emergency_scope_limitation
        end

        context "when the hearing date is present" do
          let(:emergency_hearing_date) { Date.current }

          it { is_expected.to be_valid }
        end

        context "when the hearing date is missing" do
          let(:emergency_hearing_date) { nil }

          it { is_expected.not_to be_valid }
        end
      end

      context "with a substantive scope limitation that requires a limitation note" do
        let(:application) do
          create(:application,
                 emergency_cost_override: false,
                 substantive_cost_override: false)
        end

        let(:proceeding_one) do
          create(:proceeding, :se013a,
                 legal_aid_application: application,
                 client_involvement_type_ccms_code: "A",
                 client_involvement_type_description: "Applicant/claimant/petitioner",
                 used_delegated_functions: false,
                 used_delegated_functions_on: nil,
                 accepted_substantive_defaults: false,
                 accepted_emergency_defaults: true,
                 substantive_level_of_service: "3",
                 substantive_level_of_service_name: "Full Representation",
                 substantive_level_of_service_stage: "8",
                 no_scope_limitations: true)
        end

        let(:substantive_scope_limitation) do
          create(:scope_limitation,
                 proceeding: proceeding_one,
                 scope_type: :substantive,
                 code: "APL13",
                 meaning: "High Court-limited steps (resp)",
                 description: "Limited to representation as respondent on an appeal to the High Court, limited to",
                 limitation_note: substantive_limitation_note)
        end

        before do
          proceeding_one
          substantive_scope_limitation
        end

        context "when the limitation note is present" do
          let(:substantive_limitation_note) { "some note" }

          it { is_expected.to be_valid }
        end

        context "when the limitation note is missing" do
          let(:substantive_limitation_note) { nil }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
