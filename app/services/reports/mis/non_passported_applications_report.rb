module Reports
  module MIS
    class NonPassportedApplicationsReport
      EXCLUDED_STATES = %w[use_ccms].freeze
      START_DATE = Time.new(2020, 9, 21, 0, 0, 0)
      END_TIME = Date.today.end_of_day

      def run
        csv_string = CSV.generate do |csv|
          csv << NonPassportedApplicationCsvLine.header_row
          legal_aid_applications.find_each(batch_size: 100) do |legal_aid_application|
            csv << NonPassportedApplicationCsvLine.call(legal_aid_application)
          end
        end
        csv_string
      end

      private

      def legal_aid_applications
        LegalAidApplication.joins(:state_machine)
                           .where(created_at: [START_DATE..END_TIME])
                           .where(state_machine_proxies: { type: 'NonPassportedStateMachine' })
                           .order(:created_at)
      end
    end
  end
end
