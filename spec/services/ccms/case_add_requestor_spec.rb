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
             account_type: 'Bank Current'
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
             supervisor_user_id: 7_008_010,
             fee_earner_contact_id: 4_925_152
    end

    let(:proceeding_type_1) do
      double ProceedingType,
             ccms_category_law_code: 'MAT',
             ccms_category_law: 'Family',
             ccms_matter: 'Domestic Abuse',
             case_id: 'P_11594790',
             status: 'Draft',
             lead_proceeding_indicator: true,
             ccms_code: 'DA004',
             description: 'to be represented on an application for a non-molestation order. ',
             ccms_matter_code: 'MINJN',
             scope_limitations: [scope_limitation_1, scope_limitation_2],
             default_level_of_service: 3,
             proportionality_question: 'Yes',
             includes_child: 'No',
             expert_cost_family: 100.0,
             ca_gateway_applies?: false,
             predicted_cost_family: 5300.0,
             schedule_1?: false,
             counsel_fee_family: 100.0,
             generate_warning_letter_sent_block?: true,
             warning_letter_sent?: false,
             generate_police_notified_block?: true,
             police_notified?: true,
             generate_work_in_scheme_1_block?: false,
             work_in_scheme_1?: nil,
             generate_inj_respondent_capacity_block?: true,
             inj_respondent_capacity?: true,
             lead_proceeding_merits?: true,
             meaning: 'Non-molestation order-Domestic Abuse',
             dv_gateway_applies?: false,
             generate_x_border_lar_criteria_block?: false,
             x_border_disputes_lar_criteria?: nil,
             generate_bail_conditions_set_block?: true,
             bail_conditions_set?: false,
             disbursement_cost_family: 100.0,
             generate_child_parties_criteria_block?: false,
             child_parties_criteria?: nil,
             involving_children: 'No',
             dom_violence_waiver_applies: 'Yes',
             lead_proceeding?: true,
             generate_injunction_reason_no_warning_letter_block?: true,
             reason_no_injunction_warning_letter: 'Too dangerous',
             involving_injunction: 'Yes',
             fin_rep_category: 'Domestic Violence',
             matter_type_meaning: 'Domestic Abuse',
             generate_injunction_recent_incident_detail_block?: true,
             injunction_recent_incident_detail: '29/03/2019',
             lar_gateway?: false
    end

    let(:proceeding_type_2) do
      double ProceedingType,
             ccms_category_law_code: 'MAT',
             ccms_category_law: 'Family',
             ccms_matter: 'Children-Section 8 orders',
             case_id: 'P_11594793',
             status: 'Draft',
             lead_proceeding_indicator: false,
             ccms_code: 'SE014',
             description: 'to be represented on an application for a child arrangements order - where the child(ren) will live  ',
             ccms_matter_code: 'KSEC8',
             scope_limitations: [scope_limitation_1, scope_limitation_3],
             default_level_of_service: 1,
             proportionality_question: 'No',
             includes_child: 'Yes',
             expert_cost_family: 0.0,
             ca_gateway_applies?: true,
             predicted_cost_family: 5000.0,
             schedule_1?: true,
             counsel_fee_family: 0.0,
             generate_warning_letter_sent_block?: false,
             warning_letter_sent?: nil,
             generate_police_notified_block?: false,
             police_notified?: nil,
             generate_work_in_scheme_1_block?: true,
             work_in_scheme_1?: true,
             generate_inj_respondent_capacity_block?: false,
             inj_respondent_capacity?: nil,
             lead_proceeding_merits?: false,
             meaning: 'CAO residence',
             dv_gateway_applies?: true,
             generate_x_border_lar_criteria_block?: true,
             x_border_disputes_lar_criteria?: false,
             generate_bail_conditions_set_block?: false,
             bail_conditions_set?: nil,
             disbursement_cost_family: 0.0,
             generate_child_parties_criteria_block?: true,
             child_parties_criteria?: false,
             involving_children: 'Yes',
             dom_violence_waiver_applies: 'No',
             lead_proceeding?: false,
             generate_injunction_reason_no_warning_letter_block?: false,
             reason_no_injunction_warning_letter: nil,
             involving_injunction: 'No',
             fin_rep_category: 'Private Law Children',
             matter_type_meaning: 'Section 8 orders',
             generate_injunction_recent_incident_detail_block?: false,
             injunction_recent_incident_detail: nil,
             lar_gateway?: true
    end

    let(:vehicle_1) do
      double 'Vehicle',
             in_regular_use?: true,
             date_of_purchase: Date.new(2015, 12, 1),
             make: 'Ford',
             model: 'Fiesta',
             registration_number: 'AB11 ABC',
             purchase_price: 5000.0,
             current_market_value: 500.0,
             value_of_loan_outstanding: 0.0,
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
             vehicles: [vehicle_1],
             wage_slips: [wage_slip_1],
             means_assessment_result: means_assessment_result,
             main_dwelling_third_party_name: 'Mrs Fabby Fabby',
             main_dwelling_third_party_relationship: 'Ex-Partner',
             main_dwelling_third_party_percentage: 50
    end

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
          requestor = described_class.new(legal_aid_application)
          allow(requestor).to receive(:transaction_request_id).and_return('201904011604570390059770759')
          filename = File.join(Rails.root, 'tmp', 'generated_add_case_request.xml')
          File.open(filename, 'w') do |fp|
            fp.puts "<!-- generated by rspec #{Time.now} -->"
            fp.puts requestor.formatted_xml
          end
        end
      end
    end

    context 'private_methods' do
      let(:requestor) { described_class.new(legal_aid_application) }
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
          }.to raise_error RuntimeError, 'Unknown response type: numeric'
        end
      end
    end
  end
end
