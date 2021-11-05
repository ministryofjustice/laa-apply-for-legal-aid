module HMRC
  module Interface
    class SubmissionService < BaseService
      def call
        raw_response = post_request
        parsed_response = parse_json_response(raw_response.body)
        case raw_response.status
        when 202
          parsed_response
        else
          raise HMRC::SubmissionError.new(detailed_error(parsed_response, hmrc_interface_url), raw_response.status)
        end
      end

      def hmrc_interface_url
        File.join(host, url_path)
      end

      def request_body
        @request_body ||= { filter: applicant_values.merge(date_values) }.to_json
      end

      private

      def application
        @application ||= @hmrc_response.legal_aid_application
      end

      def use_case
        @use_case ||= @hmrc_response.use_case
      end

      def applicant_values
        @applicant_values ||= application.applicant.json_for_hmrc
      end

      def date_values
        @date_values ||= { start_date: application.transaction_period_start_on, end_date: application.transaction_period_finish_on }
      end

      def post_request
        conn.post do |request|
          request.url url_path
          request.headers = headers
          request.body = request_body
        end
      rescue StandardError => e
        catch_and_record_exception(e)
      end

      def url_path
        @url_path ||= "api/v1/submission/create/#{use_case}"
      end
    end
  end
end
