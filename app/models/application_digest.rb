class ApplicationDigest < ApplicationRecord
  COLUMNS_TO_OMIT = %w[id updated_at created_at].freeze
  BOOLEAN_COLUMNS = %w[
    use_ccms
    passported
    df_used
    employed
    hmrc_data_used
    referred_to_caseworker
    has_partner
    contrary_interest
    non_means_tested
  ].freeze

  class << self
    def create_or_update!(legal_aid_application_id)
      attrs = map_attrs(legal_aid_application_id)
      rec = find_by(legal_aid_application_id:)
      rec.nil? ? create!(attrs) : rec.update!(attrs)
    end

    def column_headers
      columns.map(&:name) - COLUMNS_TO_OMIT
    end

  private

    def map_attrs(application_id)
      laa = LegalAidApplication.find application_id
      {
        legal_aid_application_id: laa.id,
        firm_name: laa.provider.firm.name,
        provider_username: laa.provider.username,
        date_started: laa.created_at.to_date,
        date_submitted: laa.merits_submitted_at,
        days_to_submission: calendar_days_to_submission(laa),
        use_ccms: laa.state == "use_ccms",
        matter_types: matter_types(laa),
        proceedings: proceedings(laa),
        passported: laa.passported?,
        df_used: laa.used_delegated_functions?,
        earliest_df_date: laa.earliest_delegated_functions_date,
        df_reported_date: laa.earliest_delegated_functions_reported_date,
        working_days_to_report_df: working_days_to_report(laa),
        employed: laa.applicant.employed?,
        hmrc_data_used: determine_hmrc_data_used?(laa),
        referred_to_caseworker: determine_caseworker_review?(laa),
        true_layer_path: laa.truelayer_path?,
        bank_statements_path: laa.bank_statement_upload_path?,
        true_layer_data: laa.bank_transactions.any?,
        has_partner: laa.applicant_has_partner?,
        contrary_interest: laa.applicant_has_partner? ? !laa.applicant_has_partner_with_no_contrary_interest? : nil,
        partner_dwp_challenge: laa&.partner&.shared_benefit_with_applicant? || nil,
        applicant_age: applicant_age(laa),
        non_means_tested: laa.non_means_tested?,
      }
    end

    def calendar_days_to_submission(laa)
      return nil if laa.merits_submitted_at.nil?

      (laa.merits_submitted_at.to_date - laa.created_at.to_date) + 1
    end

    def matter_types(laa)
      laa.proceedings.pluck(:matter_type).uniq.sort.join(";")
    end

    def proceedings(laa)
      laa.proceedings.pluck(:ccms_code).sort.join(";")
    end

    def working_days_to_report(laa)
      return nil if laa.earliest_delegated_functions_reported_date.nil?

      WorkingDayCalculator.working_days_between(laa.earliest_delegated_functions_date, laa.earliest_delegated_functions_reported_date) + 1
    end

    def determine_hmrc_data_used?(laa)
      status = HMRC::StatusAnalyzer.call(laa)
      case status
      when :employed_journey_not_enabled,
        :provider_not_enabled_for_employed_journey,
        :applicant_not_employed,
        :applicant_multiple_employments,
        :applicant_no_hmrc_data,
        :applicant_unexpected_employment_data
        false
      when :applicant_single_employment
        true
      else
        raise "Unexpected response from HMRC::StatusAnalyser #{status.inspect}"
      end
    end

    def determine_caseworker_review?(laa)
      # return false if the assessment hasn't been done yet
      return false if laa.cfe_result.nil? || laa.cfe_result.result.nil?

      CCMS::ManualReviewDeterminer.new(laa).manual_review_required?
    end

    def applicant_age(laa)
      laa.applicant.age
    rescue NoMethodError
      nil
    end
  end

  def to_google_sheet_row
    ApplicationDigest.column_headers.map { |column_name| format_column(column_name, __send__(column_name)) }
  end

  # Google sheets doesn't recognise Ruby true and false
  def format_column(column_name, value)
    column_name.in?(BOOLEAN_COLUMNS) ? value.to_s.upcase : value
  end
end
