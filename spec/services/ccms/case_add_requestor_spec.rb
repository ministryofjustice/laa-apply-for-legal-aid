# add_case_requestor_spec.rb
require 'rails_helper'

module CCMS # rubocop:disable Metrics/ModuleLength
  RSpec.describe CaseAddRequestor do
    let(:scope_limitation_1) do
      double 'ScopeLimitation',
             limitation: 'CV118',
             wording: 'Limited to all steps up to and including the hearing on 01/04/2019',
             delegated_functions_apply: true
    end

    let(:aa019_text) do
      <<~ENDOFTEXT
        As to proceedings under Part IV Family Law Act 1996 limited to all
        steps up to and including obtaining and serving a final order and in
        the event of breach leading to the exercise of a power of arrest to
        representation on the consideration of the breach by the court (but
        excluding applying for a warrant of arrest, if not attached, and
        representation in contempt proceedings).
      ENDOFTEXT
    end

    let(:scope_limitation_2) do
      double 'ScopeLimitation',
             limitation: 'AA019',
             wording: aa019_text,
             delegated_functions_apply: false
    end

    let(:scope_limitation_3) do
      double 'ScopeLimitation',
             limitation: 'FM049',
             wording: 'Limited to all steps up to and including trial/final hearing and any action necessary to implement (but not enforce) the judgment or order.',
             delegated_functions_apply: false
    end

    let(:bank_provider) do
      double BankProvider,
             name: 'Mock bank'
    end

    let(:bank_account_1) do
      double BankAccount,
             display_name: 'the bank account1',
             receives_wages?: true,
             receives_benefits?: true,
             receives_tax_credits?: false,
             balance: 100.0,
             account_number: '12345678',
             bank_provider: bank_provider,
             account_type_label: 'Bank Current'
    end

    let(:applicant) do
      double Applicant,
             ccms_reference_number: '7263259',
             first_name: 'Dave',
             last_name: 'Fabby',
             preferred_address: 'CLIENT',
             bank_accounts: [bank_account_1]
    end

    let(:provider) do
      double Provider,
             firm_id: 19_148,
             office_id: 137_570,
             user_login_id: 4_953_649,
             contact_user_id: 4_953_649,
             supervisor_contact_id: 7_008_010,
             fee_earner_contact_id: 4_925_152
    end

    let(:proceeding_type_1) do
      double ProceedingType,
             action_damages_against_police: false,
             appeal_in_supreme_court: false,
             available_amendment_only: 'No',
             bail_conditions_set?: false,
             ca_gateway_applies?: false,
             case_id: 'P_11594790',
             ccms_category_law: 'Family',
             ccms_category_law_code: 'MAT',
             ccms_code: 'DA004',
             ccms_matter: 'Domestic Abuse',
             ccms_matter_code: 'MINJN',
             child_abduction: 'No',
             child_parties_criteria?: false,
             client_bringing_or_defending: false,
             client_defendant_3rd_pty: false,
             client_inv_type_appellant: false,
             client_inv_type_bring_3rd_pty: false,
             client_inv_type_bringing_counter: false,
             client_inv_type_bringing_procs: true,
             client_inv_type_child: false,
             client_inv_type_def_counter: false,
             client_inv_type_defend_procs: false,
             client_inv_type_interpleader: false,
             client_inv_type_intervenor: false,
             client_inv_type_joined_party: false,
             client_inv_type_other: false,
             client_inv_type_personal_rep: false,
             client_involvement_type: 'A',
             client_involvement: 'Applicant/Claimant/Petitioner',
             counsel_fee_family: 100.0,
             damages_against_police: 'No',
             default_level_of_service: 3,
             delegated_functions_date: Date.new(2019, 4, 1),
             description: 'to be represented on an application for a non-molestation order.',
             disbursement_cost_family: 100.0,
             dom_violence_waiver_applies: 'Yes',
             dv_gateway_applies?: false,
             expert_cost_family: 100.0,
             family_prospects_of_success: '50% or Better',
             fam_prosp_50_or_better: true,
             fam_prosp_border_uncert_poor: false,
             fam_prosp_borderline_uncert: false,
             fam_prosp_good: false,
             fam_prosp_marginal: false,
             fam_prosp_poor: false,
             fam_prosp_uncertain: false,
             fam_prosp_very_good: false,
             fam_prosp_very_poor: false,
             fin_rep_category: 'Domestic Violence',
             generate_bail_conditions_set_block?: true,
             generate_child_parties_criteria_block?: false,
             generate_inj_respondent_capacity_block?: true,
             generate_injunction_reason_no_warning_letter_block?: true,
             generate_injunction_recent_incident_detail_block?: true,
             generate_police_notified_block?: true,
             generate_warning_letter_sent_block?: true,
             generate_work_in_scheme_1_block?: false,
             generate_x_border_lar_criteria_block?: false,
             high_cost_case_routing: 'VHCC',
             immigration_related: false,
             immigration_question_applies: 'No',
             includes_child: 'No',
             inj_respondent_capacity?: true,
             injunction_recent_incident_detail: '29/03/2019',
             involving_children: 'No',
             involving_injunction: 'Yes',
             judicial_review: false,
             lar_gateway?: false,
             lead_proceeding?: true,
             lead_proceeding_indicator: false,
             lead_proceeding_merits?: true,
             level_of_service: 3,
             level_of_service_fhh: false,
             level_of_service_fr: true,
             level_of_serv_ih: false,
             level_of_serv_inquest: false,
             limitation_desc: 'MULTIPLE',
             matrimonial_proceeding: 'No',
             matter_type_child_abduction: 'No',
             matter_type_meaning: 'Domestic Abuse',
             matter_type_private_family: 'Yes',
             matter_type_public_family: 'No',
             matter_type_stand_alone: 'No',
             meaning: 'Non-molestation order-Domestic Abuse',
             new_or_existing: 'NEW',
             new_or_existing_merits: 'NEW',
             non_quantifiable_remedy: false,
             outcome_no_outcome: true,
             overwhelming_importance: false,
             police_notified?: true,
             predicted_cost_family: 5300.0,
             private_funding_applicable: false,
             private_funding_considered: 'No',
             proc_care_superv_or_related: 'No',
             proc_involving_fin_and_prop: 'No',
             proc_is_merits_tested: 'Yes',
             proc_is_sca_or_related: 'No',
             proc_is_sca_appeal: false,
             proc_outcome_recorded: false,
             proc_possession: 'No',
             proc_register_foreign_order: 'No',
             proc_related_sca_or_related: false,
             proc_subject_to_dp_check: 'Yes',
             proc_subject_to_mediation: 'Yes',
             proc_upper_tribunal: 'No',
             proceeding_application_type: 'Both',
             proceeding_case_owner_scu: false,
             proceeding_level_of_service: 'Full Representation',
             proceeding_limitation_meaning: 'MULTIPLE',
             proceeding_new_or_existing: 'NEW',
             proceeding_stand_alone: 'No',
             proceeding_type: 'proc error',
             profit_cost_family: 5_000.0,
             proportionality_question: 'Yes',
             prospects_of_success: 'FA',
             reason_no_injunction_warning_letter: 'Too dangerous',
             related_proceeding: false,
             related_sca_or_related: false,
             requested_scope: 'MULTIPLE',
             routing_for_proceeding: 'Standard Family Merits',
             sca_appeal_final_order: false,
             schedule_1?: false,
             scope_limit_is_default: false,
             scope_limitations: [scope_limitation_1, scope_limitation_2],
             significant_wider_public_interest: false,
             smod_applicable: 'No',
             status: 'draft',
             warning_letter_sent?: false,
             work_in_scheme_1?: nil,
             x_border_disputes_lar_criteria?: false
    end

    let(:proceeding_type_2) do
      double ProceedingType,
             action_damages_against_police: false,
             appeal_in_supreme_court: false,
             available_amendment_only: 'No',
             bail_conditions_set?: false,
             ca_gateway_applies?: true,
             case_id: 'P_11594793',
             ccms_category_law: 'Family',
             ccms_category_law_code: 'MAT',
             ccms_code: 'SE014',
             ccms_matter: 'Children-Section 8 orders',
             ccms_matter_code: 'KSEC8',
             child_abduction: 'No',
             child_parties_criteria?: false,
             client_bringing_or_defending: false,
             client_defendant_3rd_pty: false,
             client_inv_type_appellant: false,
             client_inv_type_bring_3rd_pty: false,
             client_inv_type_bringing_counter: false,
             client_inv_type_bringing_procs: true,
             client_inv_type_child: false,
             client_inv_type_def_counter: false,
             client_inv_type_defend_procs: false,
             client_inv_type_interpleader: false,
             client_inv_type_intervenor: false,
             client_inv_type_joined_party: false,
             client_inv_type_other: false,
             client_inv_type_personal_rep: false,
             client_involvement_type: 'A',
             client_involvement: 'Applicant/Claimant/Petitioner',
             counsel_fee_family: 0.0,
             damages_against_police: 'No',
             default_level_of_service: 1,
             delegated_functions_date: Date.new(2019, 4, 1),
             description: 'to be represented on an application for a child arrangements order ?where the child(ren) will live',
             disbursement_cost_family: 0.0,
             dom_violence_waiver_applies: 'No',
             dv_gateway_applies?: true,
             expert_cost_family: 0.0,
             family_prospects_of_success: '50% or Better',
             fam_prosp_50_or_better: true,
             fam_prosp_border_uncert_poor: false,
             fam_prosp_borderline_uncert: false,
             fam_prosp_good: false,
             fam_prosp_marginal: false,
             fam_prosp_poor: false,
             fam_prosp_uncertain: false,
             fam_prosp_very_good: false,
             fam_prosp_very_poor: false,
             fin_rep_category: 'Private Law Children',
             generate_bail_conditions_set_block?: false,
             generate_child_parties_criteria_block?: true,
             generate_inj_respondent_capacity_block?: false,
             generate_injunction_reason_no_warning_letter_block?: false,
             generate_injunction_recent_incident_detail_block?: false,
             generate_police_notified_block?: false,
             generate_warning_letter_sent_block?: false,
             generate_work_in_scheme_1_block?: true,
             generate_x_border_lar_criteria_block?: true,
             high_cost_case_routing: 'VHCC',
             immigration_related: false,
             immigration_question_applies: 'No',
             includes_child: 'Yes',
             inj_respondent_capacity?: true,
             injunction_recent_incident_detail: '29/03/2019',
             involving_children: 'Yes',
             involving_injunction: 'No',
             judicial_review: false,
             lar_gateway?: true,
             lead_proceeding?: false,
             lead_proceeding_indicator: false,
             lead_proceeding_merits?: false,
             level_of_service: 3,
             level_of_service_fhh: false,
             level_of_service_fr: true,
             level_of_serv_ih: false,
             level_of_serv_inquest: false,
             limitation_desc: 'MULTIPLE',
             matrimonial_proceeding: 'No',
             matter_type_child_abduction: 'No',
             matter_type_meaning: 'Section 8 orders',
             matter_type_private_family: 'Yes',
             matter_type_public_family: 'No',
             matter_type_stand_alone: 'No',
             meaning: 'CAO residence',
             new_or_existing: 'NEW',
             new_or_existing_merits: 'NEW',
             non_quantifiable_remedy: false,
             outcome_no_outcome: true,
             overwhelming_importance: false,
             police_notified?: true,
             predicted_cost_family: 5000.0,
             private_funding_applicable: false,
             private_funding_considered: 'No',
             proc_care_superv_or_related: 'No',
             proc_involving_fin_and_prop: 'No',
             proc_is_merits_tested: 'Yes',
             proc_is_sca_or_related: 'No',
             proc_is_sca_appeal: false,
             proc_outcome_recorded: false,
             proc_possession: 'No',
             proc_register_foreign_order: 'No',
             proc_related_sca_or_related: false,
             proc_subject_to_dp_check: 'Yes',
             proc_subject_to_mediation: 'Yes',
             proc_upper_tribunal: 'No',
             proceeding_application_type: 'Both',
             proceeding_case_owner_scu: false,
             proceeding_level_of_service: 'Full Representation',
             proceeding_limitation_meaning: 'MULTIPLE',
             proceeding_new_or_existing: 'NEW',
             proceeding_stand_alone: 'No',
             proceeding_type: 'proc error',
             profit_cost_family: 5_000.0,
             proportionality_question: 'No',
             prospects_of_success: 'FA',
             reason_no_injunction_warning_letter: 'Too dangerous',
             related_proceeding: false,
             related_sca_or_related: false,
             requested_scope: 'MULTIPLE',
             routing_for_proceeding: 'Standard Family Merits',
             sca_appeal_final_order: false,
             schedule_1?: true,
             scope_limit_is_default: false,
             scope_limitations: [scope_limitation_1, scope_limitation_3],
             significant_wider_public_interest: false,
             smod_applicable: 'No',
             status: 'draft',
             warning_letter_sent?: false,
             work_in_scheme_1?: true,
             x_border_disputes_lar_criteria?: false
    end

    let(:vehicle_1) do
      double 'Vehicle',
             used_regularly?: true,
             purchased_on: Date.new(2015, 12, 1),
             make: 'Ford',
             model: 'Fiesta',
             registration_number: 'AB11 ABC',
             purchase_price: 5000.0,
             estimated_value: 500.0,
             payment_remaining: 0.0,
             instance_label: 'the cars & motor vehicle1'
    end

    let(:wage_slip_1) do
      double 'WageSlip',
             description: '300000333864:EMPLOYMENT_CLIENT_001:CLI_NON_HM_WAGE_SLIP_001',
             gross_pay: 1000.0,
             paye_deducted: 300.0,
             ni_deducted: 100.0,
             pay_period: Date.new(2019, 3, 29)
    end

    let(:means_assessment_result) do
      double 'MeansAssessmentResult',
             capital_contribution: 0.0
    end

    let(:legal_aid_application) do
      double LegalAidApplication,
             ccms_reference_number: '300000333864',
             provider_case_reference_number: 'CCMS_Apply_Test_Case',
             requested_amount: 5000.0,
             applicant: applicant,
             provider: provider,
             proceeding_types: [proceeding_type_1, proceeding_type_2],
             lead_proceeding: proceeding_type_1,
             vehicle: vehicle_1,
             wage_slips: [wage_slip_1],
             means_assessment_result: means_assessment_result,
             main_dwelling_third_party_name: 'Mrs Fabby Fabby',
             main_dwelling_third_party_relationship: 'Ex-Partner',
             main_dwelling_third_party_percentage: 50,
             opponents: [other_party_2],
             ccms_submissions: ccms_submissions_collection,
             opponent_other_parties: [other_party_1, other_party_2],
             most_recent_ccms_submission: ccms_submission
    end

    let(:other_party_1) { create :opponent, :child }

    let(:other_party_2) { create :opponent, :ex_spouse }

    let(:ccms_submissions_collection) do
      double 'Collection of CCMS::Submission records',
             most_recent: ccms_submission
    end

    let(:ccms_submission) do
      double CCMS::Submission,
             case_ccms_reference: Faker::Number.number(12)
    end

    let(:expected_tx_id) { '201904011604570390059770759' }

    let(:submission) do
      double Submission,
             legal_aid_application: legal_aid_application,
             case_ccms_reference: 1_234_567_890,
             applicant_ccms_reference: 9_876_543_210
    end
    let(:requestor) { described_class.new(submission, {}) }

    describe 'XML request' do
      # This test is non-functional at the moment.
      # It outputs to a temp file, which can then be compared with the expected xml using diff merge
      # The only differences should be:
      # - the first comment line on the generated file
      # - names of the valuable possessions
      # - the wording of scope of limitations CV118 (whether it includes a date or not)
      # - spacing issues
      # - single quote/double quote mismatch
      # - missing elements for opponents
      it 'generates the expected XML' do
        Timecop.freeze Time.new(2019, 4, 1, 16, 4, 57.039) do
          allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
          filename = File.join(Rails.root, 'tmp', 'generated_add_case_request.xml')
          File.open(filename, 'w') do |fp|
            fp.puts "<!-- generated by rspec #{Time.now} -->"
            fp.puts requestor.formatted_xml
          end
        end
      end

      describe '#call' do
        let(:soap_client_double) { Savon.client(env_namespace: :soap, wsdl: requestor.__send__(:wsdl_location)) }
        let(:expected_soap_operation) { :create_case_application }
        let(:expected_xml) { requestor.__send__(:request_xml) }

        before do
          Timecop.freeze
          expect(requestor).to receive(:soap_client).and_return(soap_client_double)
        end

        it 'calls the savon soap client' do
          expect(soap_client_double).to receive(:call).with(expected_soap_operation, xml: expected_xml)
          requestor.call
        end
      end
    end

    context 'private_methods' do
      let(:options) { {} }
      context '#extract_response_value' do
        it 'raises if an unknown response type is given in the config' do
          config = {
            value: 4664,
            br100_meaning: 'n/a',
            response_type: 'numeric',
            user_defined: true
          }
          expect {
            requestor.__send__(:extract_response_value, config, options)
          }.to raise_error CCMS::CcmsError, 'Unknown response type: numeric'
        end
      end

      # this test is only necessary as the concept of a lead proceeding has not yet been implemented for a
      # legal_aid_application. when it has been implemented this test will not be necessary and can be removed
      describe '#lead_proceeding' do
        it 'returns the lead proceeding' do
          expect(requestor.__send__(:lead_proceeding)).to eq proceeding_type_1
        end
      end
    end
  end
end
