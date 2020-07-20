module Reports
  module MIS
    class ApplicationDetailsReport
      SUBMITTED_STATES = %w[submitting_assessment assessment_submitted].freeze
      def run
        csv_string = CSV.generate do |csv|
          csv << ApplicationDetailCsvLine.header_row
          legal_aid_applications.find_each(batch_size: 100) do |legal_aid_application|
            csv << ApplicationDetailCsvLine.call(legal_aid_application)
          end
        end
        csv_string
      end

      private

      def legal_aid_applications
        LegalAidApplication.joins(:state_machine).where(state_machine_proxies: { aasm_state: SUBMITTED_STATES }).order(:created_at)
      end
    end
  end
end
