module CFE
  class BaseService
    def self.call(submission)
      new(submission).call
    end

    def initialize(submission)
      @submission = submission
    end

    def call
      @response = query_cfe_service
      process_response
    end

    private

    def conn
      @conn ||= Faraday.new(url: cfe_url_host)
    end

    def cfe_url_host
      ENV['CHECK_FINANCIAL_ELIGIBILITY_URL']
    end

    def cfe_url
      cfe_url_host + cfe_url_path
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
    # rescue StandardError => e
    #   raise_exception_error(e)
    end

    def raise_exception_error(err)
      @submission.submission_histories.create!(
        url: cfe_url,
        http_method: 'POST',
        request_payload: request_body,
        http_response_status: err.respond_to?(:http_status) ? err.http_status : nil,
        error_message: formatted_error_message(err),
        error_backtrace: err.backtrace.join("\n")
      )
      raise CFE::SubmissionError.new(formatted_error_message(err), err)
    end

    def formatted_error_message(err)
      "#{self.class} received #{err.class}: #{err.message}"
    end

    def write_submission_history(raw_response)
      @submission.submission_histories.create!(
        url: cfe_url,
        http_method: 'POST',
        request_payload: request_body,
        http_response_status: raw_response.status,
        response_payload: raw_response.body
      )
    end
  end
end
