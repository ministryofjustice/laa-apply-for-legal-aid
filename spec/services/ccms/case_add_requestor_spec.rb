# add_case_requestor_spec.rb
require 'rails_helper'

module CCMS # rubocop:disable Metrics/ModuleLength
  RSpec.describe CaseAddRequestor do
    context 'using dummy data' do # This context will eventually be removed
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
               has_wages?: true,
               has_benefits?: true,
               has_tax_credits?: false,
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
               selected_office_id: 137_570,
               username: 4_953_649,
               contact_user_id: 4_953_649,
               supervisor_contact_id: 7_008_010,
               fee_earner_contact_id: 4_925_152
      end

      let(:proceeding_type_1) do
        double ProceedingType,
               bail_conditions_set?: false,
               case_id: 'P_11594790',
               ccms_category_law: 'Family',
               ccms_category_law_code: 'MAT',
               ccms_code: 'DA004',
               ccms_matter: 'Domestic Abuse',
               ccms_matter_code: 'MINJN',
               delegated_functions_date: Date.new(2019, 4, 1),
               description: 'to be represented on an application for a non-molestation order.',
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
               inj_respondent_capacity?: true,
               injunction_recent_incident_detail: '29/03/2019',
               lead_proceeding_indicator: false,
               level_of_service: 3,
               matter_type_meaning: 'Domestic Abuse',
               meaning: 'Non-molestation order-Domestic Abuse',
               police_notified?: true,
               proceeding_level_of_service: 'Full Representation',
               reason_no_injunction_warning_letter: 'Too dangerous',
               requested_scope: 'MULTIPLE',
               scope_limitations: [scope_limitation_1, scope_limitation_2],
               status: 'draft',
               warning_letter_sent?: false
      end

      let(:proceeding_type_2) do
        double ProceedingType,
               bail_conditions_set?: false,
               case_id: 'P_11594793',
               ccms_category_law: 'Family',
               ccms_category_law_code: 'MAT',
               ccms_code: 'SE014',
               ccms_matter: 'Children-Section 8 orders',
               ccms_matter_code: 'KSEC8',
               delegated_functions_date: Date.new(2019, 4, 1),
               description: 'to be represented on an application for a child arrangements order ?where the child(ren) will live',
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
               inj_respondent_capacity?: true,
               injunction_recent_incident_detail: '29/03/2019',
               lead_proceeding_indicator: false,
               level_of_service: 3,
               matter_type_meaning: 'Section 8 orders',
               meaning: 'CAO residence',
               police_notified?: true,
               proceeding_level_of_service: 'Full Representation',
               reason_no_injunction_warning_letter: 'Too dangerous',
               requested_scope: 'MULTIPLE',
               scope_limitations: [scope_limitation_1, scope_limitation_3],
               status: 'draft',
               warning_letter_sent?: false
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

      let(:respondent) do
        double Respondent,
               understands_terms_of_court_order?: true,
               understands_terms_of_court_order_details: '',
               warning_letter_sent?: false,
               warning_letter_sent_details: 'Standard cease and desist letter',
               police_notified?: true,
               police_notified_details: '',
               bail_conditions_set?: true,
               bail_conditions_set_details: 'The judge was bonkers',
               no_warning_letter_sent?: true
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
               most_recent_ccms_submission: ccms_submission,
               used_delegated_functions?: true,
               used_delegated_functions_on: Date.today,
               ccms_case_reference: 'P_88000001',
               respondent: respondent
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

      describe 'Full XML request' do
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
            save_xml_in_temp_file(requestor.formatted_xml)
          end
        end
      end
    end

    describe '#call' do
      let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_everything, populate_vehicle: true }
      let(:submission) { create :submission, :case_ref_obtained, legal_aid_application: legal_aid_application }
      let(:requestor) { described_class.new(submission, {}) }
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

    context 'private_methods' do
      let(:options) { {} }
      let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_everything, populate_vehicle: true }
      let(:submission) { create :submission, :case_ref_obtained, legal_aid_application: legal_aid_application }
      let(:requestor) { described_class.new(submission, {}) }
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

      describe '#evaluate_generate_block_method?' do
        context 'when true' do
          let(:config) { { generate_block?: true } }
          it 'returns true' do
            requestor.__send__(:evaluate_generate_block_method, config, options)
          end
        end

        context 'when false' do
          let(:config) { { generate_block?: false } }
          it 'returns false' do
            requestor.__send__(:evaluate_generate_block_method, config, options)
          end
        end

        context 'when a method name' do
          let(:dummy_opponent) { double 'Dummy opponent' }
          let(:config)  { { generate_block?: 'opponent_my_special_method' } }
          let(:options) { { opponent: dummy_opponent } }
          let(:expected_result) { 'result from calling my_special_method on dummy_oppponent' }

          it 'returns the return value of the method called on the opponent' do
            allow(dummy_opponent).to receive(:my_special_method).and_return(expected_result)
            expect(requestor.__send__(:evaluate_generate_block_method, config, options)).to eq expected_result
          end
        end
      end
    end
  end
end
