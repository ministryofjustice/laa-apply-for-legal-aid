module Admin
  module LegalAidApplications
    class SubmissionsController < AdminBaseController
      before_action :authenticate_admin_user!
      before_action :load_history, only: %i[download_xml_response download_xml_request]
      layout 'admin'.freeze

      def show
        legal_aid_application
      end

      def download_xml_response
        download_data :response
      end

      def download_xml_request
        download_data :request
      end

      def download_means_report
        download_report :means
      end

      def download_merits_report
        download_report :merits
      end

      private

      def legal_aid_application
        @legal_aid_application ||= LegalAidApplication.find(params[:id])
      end

      def filename(type, id)
        "submission_history_#{id}_#{type}.xml"
      end

      def prettify_xml(source)
        Nokogiri::XML(source.delete("\n").gsub(/>\s+</, '><'))
      end

      def load_history
        @history = CCMS::SubmissionHistory.find(params[:id])
      end

      def download_data(attribute)
        data = @history.__send__(attribute)
        raise StandardError, 'No data found' if data.nil?

        send_data prettify_xml(data),
                  status: 200,
                  type: 'text/xml',
                  filename: filename(attribute, params[:id])
      end

      # :nocov:
      def download_report(attribute)
        report = legal_aid_application.send("#{attribute}_report")
        send_data report.document.download,
                  status: 200,
                  type: 'application/pdf',
                  filename: report.attachment_name
      end
      # :nocov:
    end
  end
end
