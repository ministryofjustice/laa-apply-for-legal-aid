module HMRC
  module Interface
    class SubmissionService
      def self.call(hmrc_response)
        new(hmrc_response).call
      end

      def initialize(hmrc_response)
        @application = hmrc_response.legal_aid_application
        @use_case = hmrc_response.use_case
      end

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

      def applicant_values
        @applicant_values ||= @application.applicant.json_for_hmrc
      end

      def date_values
        @date_values ||= { start_date: @application.transaction_period_start_on, end_date: @application.transaction_period_finish_on }
      end

      def conn
        @conn ||= Faraday.new(url: host, headers: headers)
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

      def bearer_token
        @bearer_token ||= OmniAuth::HMRC::Client.new.bearer_token
      end

      def url_path
        @url_path ||= "api/v1/submission/create/#{@use_case}"
      end

      def host
        Rails.configuration.x.hmrc_interface.host
      end

      def headers
        {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Authorization' => "Bearer #{bearer_token}"
        }
      end

      def catch_and_record_exception(error, http_method = 'POST')
        raise_exception_error(
          message: formatted_error_message(error),
          backtrace: error.backtrace&.join("\n"),
          http_method: http_method,
          http_status: error.respond_to?(:http_status) ? error.http_status : nil
        )
      end

      def raise_exception_error(message:, backtrace: nil, http_method: 'POST', http_status: nil)
        Rails.logger.info { { message: message, backtrace: backtrace, method: http_method, http_status: http_status } }
        raise HMRC::SubmissionError.new(message, http_status)
      end

      def formatted_error_message(err)
        "#{self.class} received #{err.class}: #{err.message}"
      end

      def parse_json_response(response_body)
        JSON.parse(response_body, symbolize_names: true)
      rescue JSON::ParserError, TypeError
        response_body || ''
      end

      def detailed_error(parsed_response, url)
        "Bad Request: URL: #{url}, details: #{parsed_response}"
      end
    end
  end
end
