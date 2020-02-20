module Reports
  module MIS
    class ApplicationDetailsReport
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
        LegalAidApplication.assessment_submitted.order(:created_at)
      end
    end
  end
end
