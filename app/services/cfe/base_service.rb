module CFE
  class BaseService
    def self.call(submission)
      new(submission).call
    end

    attr_reader :submission

    def initialize(submission)
      @submission = submission
    end

    def call
      @response = query_cfe_service
      process_response
    end

    def cfe_url
      File.join(cfe_url_host, cfe_url_path)
    end

    private

    def conn
      @conn ||= Faraday.new(url: cfe_url_host)
    end

    def cfe_url_host
      Rails.configuration.x.check_finanical_eligibility_host
    end

    def legal_aid_application
      @legal_aid_application ||= @submission.legal_aid_application
    end

    def query_cfe_service
      raw_response = post_request
      parse_json_response(raw_response.body)
      write_submission_history(raw_response)
      case raw_response.status
      when 200
        return JSON.parse(raw_response.body)
      when 422
        raise CFE::SubmissionError.new('Unprocessable entity', 422)
      else
        raise CFE::SubmissionError.new('Unsuccessful HTTP response code', raw_response.status)
      end
    end

    def parse_json_response(response_body)
      JSON.parse(response_body)
    rescue JSON::ParserError, TypeError
      response_body || ''
    end

    def post_request
      conn.post do |request|
        request.url cfe_url_path
        request.headers['Content-Type'] = 'application/json'
        request.body = request_body
      end
    rescue StandardError => e
      catch_and_record_exception(e)
    end

    # def raise_exception_error(err, http_method = 'POST')
    #   @submission.submission_histories.create!(
    #     url: cfe_url,
    #     http_method: http_method,
    #     request_payload: request_body,
    #     http_response_status: err.respond_to?(:http_status) ? err.ht/Users/stephenrichards/moj/apply/app/services/cfe/base_service.rb:91tp_status : nil,
    #     error_message: formatted_error_message(err),
    #     error_backtrace: err.backtrace&.join("\n")
    #   )
    #   raise CFE::SubmissionError.new(formatted_error_message(err), err)
    # end

    def catch_and_record_exception(error, http_method = 'POST')
      raise_exeception_error(
        message: formatted_error_message(error),
        backtrace: error.backtrace&.join("\n"),
        http_method: http_method,
        http_status: error.respond_to?(:http_status) ? error.http_status : nil
      )
    end

    def raise_exeception_error(message:, backtrace: nil, http_method: 'POST', http_status: nil)
      @submission.submission_histories.create!(
        url: cfe_url,
        http_method: http_method,
        request_payload: request_body,
        http_response_status: http_status,
        error_message: message,
        error_backtrace: backtrace
      )
      raise CFE::SubmissionError.new(message, http_status)
    end

    def formatted_error_message(err)
      "#{self.class} received #{err.class}: #{err.message}"
    end

    def write_submission_history(raw_response, http_method = 'POST')
      @submission.submission_histories.create!(
        url: cfe_url,
        http_method: http_method,
        request_payload: request_body,
        http_response_status: raw_response.status,
        response_payload: raw_response.body,
        error_message: error_message_from_response(raw_response)
      )
    end

    def error_message_from_response(raw_response)
      raw_response.status == 200 ? nil : "Unexpected response: #{raw_response.status}"
    end
  end
end
