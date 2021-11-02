class ApplicationDigest < ApplicationRecord
  class << self
    def create_or_update!(legal_aid_application_id)
      attrs = map_attrs(legal_aid_application_id)
      rec = find_by(legal_aid_application_id: legal_aid_application_id)
      rec.nil? ? create!(attrs) : rec.update!(attrs)
    end

    private

    def map_attrs(application_id) # rubocop:disable Metrics/MethodLength
      laa = LegalAidApplication.find application_id
      {
        legal_aid_application_id: laa.id,
        firm_name: laa.provider.firm.name,
        provider_username: laa.provider.username,
        date_started: laa.created_at.to_date,
        date_submitted: laa.merits_submitted_at,
        days_to_submission: calendar_days_to_submission(laa),
        use_ccms: laa.state == 'use_ccms',
        matter_types: matter_types(laa),
        proceedings: proceedings(laa),
        passported: laa.passported?,
        df_used: laa.used_delegated_functions?,
        earliest_df_date: laa.earliest_delegated_functions_date,
        df_reported_date: laa.earliest_delegated_functions_reported_date,
        working_days_to_report_df: working_days_to_report(laa)
      }
    end

    def calendar_days_to_submission(laa)
      return nil if laa.merits_submitted_at.nil?

      (laa.merits_submitted_at.to_date - laa.created_at.to_date) + 1
    end

    def matter_types(laa)
      laa.proceedings.pluck(:matter_type).uniq.sort.join(';')
    end

    def proceedings(laa)
      laa.proceedings.pluck(:ccms_code).sort.join(';')
    end

    def working_days_to_report(laa)
      return nil if laa.earliest_delegated_functions_reported_date.nil?

      WorkingDayCalculator.working_days_between(laa.earliest_delegated_functions_date, laa.earliest_delegated_functions_reported_date) + 1
    end
  end
end
