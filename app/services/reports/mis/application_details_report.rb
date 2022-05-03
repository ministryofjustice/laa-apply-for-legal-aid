require "csv"

module Reports
  module MIS
    class ApplicationDetailsReport
      def run
        generate_temp_file
        tempfile_name
      rescue StandardError => e
        notify_error(e)
      end

    private

      def generate_temp_file
        line_count = 0
          CSV.open(tempfile_name, "w") do |csv|
            csv << ApplicationDetailCsvLine.header_row
            legal_aid_application_ids.each do |laa_id|
              legal_aid_application = LegalAidApplication.find(laa_id)
              csv << ApplicationDetailCsvLine.call(legal_aid_application)
              line_count += 1
              log "#{line_count} lines created" if (line_count % 100).zero?
            end
          rescue StandardError => e
            log "#{e.class} :: #{e.message}"
        end
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

      def tempfile_name
        @tempfile_name ||= Rails.root.join("tmp/admin_report_#{string_time}.csv")
      end

      def string_time
        Time.zone.now.strftime("%F-%H-%M-%S")
      end
    end
  end
end
