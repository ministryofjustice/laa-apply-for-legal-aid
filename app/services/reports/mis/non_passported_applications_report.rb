module Reports
  module MIS
    class NonPassportedApplicationsReport
      START_DATE = Time.zone.local(2020, 9, 21, 0, 0, 0).freeze

      def run
        csv_string = CSV.generate do |csv|
          csv << NonPassportedApplicationCsvLine.header_row
          legal_aid_applications.each do |legal_aid_application|
            csv << NonPassportedApplicationCsvLine.call(legal_aid_application)
          end
        end
        csv_string
      end

      private

      def legal_aid_applications
        LegalAidApplication.joins(:state_machine)
                           .where(created_at: [START_DATE..Time.zone.today.end_of_day])
                           .where(state_machine_proxies: { type: 'NonPassportedStateMachine' })
                           .order(:created_at)
      end
    end
  end
end
