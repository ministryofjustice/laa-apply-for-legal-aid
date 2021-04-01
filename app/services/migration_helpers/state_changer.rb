# rubocop:disable Layout/LineLength
module MigrationHelpers
  class StateChanger
    STATE_CHANGES = [
      [:initiated, :entering_applicant_details, %(provider_step != 'address_lookups')],
      [:checking_client_details_answers, :checking_applicant_details, nil],
      [:client_details_answers_checked, :applicant_details_checked, %(provider_step = 'check_benefits')],
      [:client_details_answers_checked, :provider_entering_means, %|provider_step not in ('check_benefits', 'open_banking_consents', 'email_addresses', 'about_the_financial_assessments')|],
      [:client_details_answers_checked, :provider_confirming_applicant_eligibility, %|provider_step in ('check_benefits', 'open_banking_consents', 'email_addresses', 'about_the_financial_assessments')|],
      [:provider_assessing_means, :provider_entering_merits, %|provider_step in ('capital_assessment_results', 'start_chances_of_successes', 'date_client_told_incidents', 'respondents', 'statement_of_cases', 'chances_of_success', 'success_prospects')|],
      [:provider_submitted, :applicant_entering_means, nil],
      [:provider_checking_citizens_means_answers, :checking_non_passported_means, nil],
      [:provider_checked_citizens_means_answers, :provider_entering_merits, %|provider_step not in ('capital_assessment_results', 'start_chances_of_successes', 'date_client_told_incidents', 'respondents', 'statement_of_cases', 'chances_of_success', 'success_prospects')|]
    ].freeze

    def initialize(dummy_run:)
      @dummy_run = dummy_run
    end

    def up
      run(:up)
    end

    def down
      run(:down)
    end

    private

    def run(migration_direction)
      STATE_CHANGES.each do |change_details|
        old_state, new_state, where_clause = change_details
        sql = form_sql(old_state, new_state, where_clause, migration_direction)
        if @dummy_run
          Rails.logger.info sql
        else
          ActiveRecord::Base.connection.execute(sql)
        end
      end
    end

    def form_sql(old_state, new_state, where_clause, migration_direction)
      migration_direction == :up ? form_up_sql(old_state, new_state, where_clause) : form_down_sql(old_state, new_state, where_clause)
    end

    def form_up_sql(old_state, new_state, where_clause)
      sql = %(UPDATE legal_aid_applications SET state = '#{new_state}' WHERE state = '#{old_state}' )
      sql += %( AND #{where_clause}) unless where_clause.nil?
      sql
    end

    def form_down_sql(old_state, new_state, where_clause)
      sql = %(UPDATE legal_aid_applications SET state = '#{old_state}' WHERE state = '#{new_state}')
      sql += %( AND #{where_clause}) unless where_clause.nil?
      sql
    end
  end
end
# rubocop:enable Layout/LineLength
