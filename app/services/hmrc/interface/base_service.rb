module HMRC
  module Interface
    class BaseService
      def self.call(hmrc_response)
        new(hmrc_response).call
      end

      def initialize(hmrc_response)
        @hmrc_response = hmrc_response
      end

    private

      def conn
        @conn ||= Faraday.new(url: host, headers:)
      end

      def bearer_token
        @bearer_token ||= OmniAuth::HMRC::Client.new.bearer_token
      end

      def host
        Rails.configuration.x.hmrc_interface.host
      end

      def headers
        {
          "Content-Type" => "application/json",
          "Accept" => "application/json",
          "Authorization" => "Bearer #{bearer_token}",
        }
      end

      def catch_and_record_exception(error, http_method = "POST")
        raise_exception_error(
          message: formatted_error_message(error),
          backtrace: error.backtrace&.join("\n"),
          http_method:,
          http_status: error.respond_to?(:http_status) ? error.http_status : nil,
        )
      end

      def raise_exception_error(message:, backtrace: nil, http_method: "POST", http_status: nil)
        Rails.logger.info { { message:, backtrace:, method: http_method, http_status: } }
        raise HMRC::InterfaceError.new(message, http_status)
      end

      def formatted_error_message(err)
        "#{self.class} received #{err.class}: #{err.message}"
      end

      def parse_json_response(response_body)
        JSON.parse(response_body, symbolize_names: true)
      rescue JSON::ParserError, TypeError
        response_body || ""
      end

      def detailed_error(parsed_response, url)
        "Bad Request: URL: #{url}, details: #{parsed_response}"
      end
    end
  end
end
