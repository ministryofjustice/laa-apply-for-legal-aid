require 'rails_helper'

module MigrationHelpers
  RSpec.describe 'MigrationHelpers::StateChanger' do
    let!(:initiated_address_lookups) { create_app(:initiated, :address_lookups) }
    let!(:initiated_address_selections) { create_app(:initiated, :address_selections) }
    let!(:initiated_proceedings_types) { create_app(:initiated, :proceedings_types) }
    let!(:initiated_used_delegated_functions) { create_app(:initiated, :used_delegated_functions) }
    let!(:initiated_limitations) { create_app(:initiated, :limitations) }
    let!(:checking_client_details_answers_check_provider_answers) { create_app(:checking_client_details_answers, :check_provider_answers) }
    let!(:client_details_answers_checked_check_benefits) { create_app(:client_details_answers_checked, :check_benefits) }
    let!(:client_details_answers_checked_capital_introductions) { create_app(:client_details_answers_checked, :capital_introductions) }
    let!(:client_details_answers_checked_own_homes) { create_app(:client_details_answers_checked, :own_homes) }
    let!(:client_details_answers_checked_open_banking_consents) { create_app(:client_details_answers_checked, :open_banking_consents) }
    let!(:client_details_answers_checked_email_addresses) { create_app(:client_details_answers_checked, :email_addresses) }
    let!(:client_details_answers_checked_about_the_financial_assessments) { create_app(:client_details_answers_checked, :about_the_financial_assessments) }
    let!(:provider_assessing_means) { create_app(:provider_assessing_means, :respondents) }
    let!(:provider_submitted) { create_app(:provider_submitted, nil) }
    let!(:provider_checking_citizens_means_answers_means_summaries) { create_app(:provider_checking_citizens_means_answers, :means_summaries) }
    let!(:provider_checked_citizens_means_answers) { create_app(:provider_checked_citizens_means_answers, :capital_income_assessment_results) }

    context 'not a dummy run' do
      describe '#up' do
        it 'allocates the correct states' do
          StateChanger.new(dummy_run: false).up
          expect_state_changed(:initiated_address_lookups, :initiated)
          expect_state_changed(:initiated_address_selections, :entering_applicant_details)
          expect_state_changed(:initiated_proceedings_types, :entering_applicant_details)
          expect_state_changed(:initiated_used_delegated_functions, :entering_applicant_details)
          expect_state_changed(:initiated_limitations, :entering_applicant_details)
          expect_state_changed(:checking_client_details_answers_check_provider_answers, :checking_applicant_details)
          expect_state_changed(:client_details_answers_checked_check_benefits, :applicant_details_checked)
          expect_state_changed(:client_details_answers_checked_capital_introductions, :provider_entering_means)
          expect_state_changed(:client_details_answers_checked_own_homes, :provider_entering_means)
          expect_state_changed(:client_details_answers_checked_open_banking_consents, :provider_confirming_applicant_eligibility)
          expect_state_changed(:client_details_answers_checked_email_addresses, :provider_confirming_applicant_eligibility)
          expect_state_changed(:client_details_answers_checked_about_the_financial_assessments, :provider_confirming_applicant_eligibility)
          expect_state_changed(:provider_assessing_means, :provider_entering_merits)
          expect_state_changed(:provider_submitted, :applicant_entering_means)
          expect_state_changed(:provider_checking_citizens_means_answers_means_summaries, :checking_non_passported_means)
          expect_state_changed(:provider_checked_citizens_means_answers, :provider_entering_merits)
        end
      end

      describe '#down' do
        it 'changes states back to their orignal state' do
          StateChanger.new(dummy_run: false).up
          StateChanger.new(dummy_run: false).down
          expect_state_changed(:initiated_address_lookups, :initiated)
          expect_state_changed(:initiated_address_selections, :initiated)
          expect_state_changed(:initiated_proceedings_types, :initiated)
          expect_state_changed(:initiated_used_delegated_functions, :initiated)
          expect_state_changed(:initiated_limitations, :initiated)
          expect_state_changed(:checking_client_details_answers_check_provider_answers, :checking_client_details_answers)
          expect_state_changed(:client_details_answers_checked_check_benefits, :client_details_answers_checked)
          expect_state_changed(:client_details_answers_checked_capital_introductions, :client_details_answers_checked)
          expect_state_changed(:client_details_answers_checked_own_homes, :client_details_answers_checked)
          expect_state_changed(:client_details_answers_checked_open_banking_consents, :client_details_answers_checked)
          expect_state_changed(:client_details_answers_checked_email_addresses, :client_details_answers_checked)
          expect_state_changed(:client_details_answers_checked_about_the_financial_assessments, :client_details_answers_checked)
          expect_state_changed(:provider_submitted, :provider_submitted)
          expect_state_changed(:provider_checking_citizens_means_answers_means_summaries, :provider_checking_citizens_means_answers)
          expect_state_changed(:provider_checked_citizens_means_answers, :provider_checked_citizens_means_answers)
        end
      end
    end

    context 'dummy run' do
      it 'outputs to SQL statements to stdout' do
        expected_sql_statements.each do |sql|
          expect($stdout).to receive(:puts).with(sql)
        end
        StateChanger.new(dummy_run: true).up
      end

      it 'does not change the records' do
        allow($stdout).to receive(:puts)
        StateChanger.new(dummy_run: true).up
        expect_state_not_to_have_changed(:initiated_address_lookups)
        expect_state_not_to_have_changed(:initiated_address_selections)
        expect_state_not_to_have_changed(:initiated_proceedings_types)
        expect_state_not_to_have_changed(:initiated_used_delegated_functions)
        expect_state_not_to_have_changed(:initiated_limitations)
        expect_state_not_to_have_changed(:checking_client_details_answers_check_provider_answers)
        expect_state_not_to_have_changed(:client_details_answers_checked_check_benefits)
        expect_state_not_to_have_changed(:client_details_answers_checked_capital_introductions)
        expect_state_not_to_have_changed(:client_details_answers_checked_own_homes)
        expect_state_not_to_have_changed(:client_details_answers_checked_open_banking_consents)
        expect_state_not_to_have_changed(:client_details_answers_checked_email_addresses)
        expect_state_not_to_have_changed(:client_details_answers_checked_about_the_financial_assessments)
        expect_state_not_to_have_changed(:provider_submitted)
      end
    end

    def create_app(state, provider_step)
      rec = build :legal_aid_application, state: state, provider_step: provider_step
      rec.save(validate: false)
      rec
    end

    def expect_state_changed(rec, new_state)
      expect(__send__(rec).reload.state).to eq new_state.to_s
    end

    def expect_state_not_to_have_changed(rec)
      original_rec = __send__(rec)
      reloaded_rec = __send__(rec).reload
      expect(reloaded_rec.state).to eq original_rec.state
    end

    # rubocop:disable Layout/LineLength
    def expected_sql_statements
      [
        %(UPDATE legal_aid_applications SET state = 'entering_applicant_details' WHERE state = 'initiated'  AND provider_step != 'address_lookups'),
        %(UPDATE legal_aid_applications SET state = 'checking_applicant_details' WHERE state = 'checking_client_details_answers' ),
        %(UPDATE legal_aid_applications SET state = 'applicant_details_checked' WHERE state = 'client_details_answers_checked'  AND provider_step = 'check_benefits'),
        %|UPDATE legal_aid_applications SET state = 'provider_entering_means' WHERE state = 'client_details_answers_checked'  AND provider_step not in ('check_benefits', 'open_banking_consents', 'email_addresses', 'about_the_financial_assessments')|,
        %|UPDATE legal_aid_applications SET state = 'provider_confirming_applicant_eligibility' WHERE state = 'client_details_answers_checked'  AND provider_step in ('check_benefits', 'open_banking_consents', 'email_addresses', 'about_the_financial_assessments')|,
        %|UPDATE legal_aid_applications SET state = 'provider_entering_merits' WHERE state = 'provider_assessing_means'  AND provider_step in ('capital_assessment_results', 'start_merits_assessments', 'date_client_told_incidents', 'respondents', 'statement_of_cases', 'success_likely', 'success_prospects')|,
        %(UPDATE legal_aid_applications SET state = 'applicant_entering_means' WHERE state = 'provider_submitted' ),
        %(UPDATE legal_aid_applications SET state = 'checking_non_passported_means' WHERE state = 'provider_checking_citizens_means_answers' ),
        %|UPDATE legal_aid_applications SET state = 'provider_entering_merits' WHERE state = 'provider_checked_citizens_means_answers'  AND provider_step not in ('capital_assessment_results', 'start_merits_assessments', 'date_client_told_incidents', 'respondents', 'statement_of_cases', 'success_likely', 'success_prospects')|
      ]
    end
    # rubocop:enable Layout/LineLength
  end
end
