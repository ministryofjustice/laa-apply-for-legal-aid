module Reports
  module MIS
    class ApplicationDetailsReport
      def run
        csv_string = CSV.generate do |csv|
          csv << ApplicationDetailCsvLine.header_row
          legal_aid_application_ids.each do |laa_id|
            legal_aid_application = LegalAidApplication.find(laa_id)
            csv << ApplicationDetailCsvLine.call(legal_aid_application)
          end
        end
        csv_string
      end

      private

      def legal_aid_application_ids
        LegalAidApplication.order(:created_at).pluck(:id)
      end
    end
  end
end
