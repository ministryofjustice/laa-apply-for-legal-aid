module Reports
  module MIS
    class ApplicationDetailsReport
      def run
        generate_csv_string
      rescue StandardError => e
        notify_error(e)
      end

    private

      def generate_csv_string
        csv_string = CSV.generate do |csv|
          csv << ApplicationDetailCsvLine.header_row
          legal_aid_application_ids.each do |laa_id|
            legal_aid_application = LegalAidApplication.find(laa_id)
            csv << ApplicationDetailCsvLine.call(legal_aid_application)
          end
        end
        csv_string
      rescue StandardError => e
        log "generate_csv_string - #{e.message}"
        raise e
      end

      def legal_aid_application_ids
        LegalAidApplication.order(:created_at).pluck(:id)
      end

      def notify_error(err)
        message = "#{err.class} #{err.message}\n#{err.backtrace}"
        Rails.logger.error message
        Sentry.capture_message(message)
      end

      def log(message)
        Rails.logger.info "ApplicationDetailsReport - #{message}"
      end
    end
  end
end
