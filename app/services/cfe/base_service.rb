module CFE
  class BaseService
    def self.call(submission)
      new(submission).call
    end

    def initialize(submission)
      @submission = submission
      @conn = Faraday.new(url: cfe_url_host)
    end

    def call
      @response = query_cfe_service
      process_response
    end

    private

    def cfe_url_host
      'http://localhost:3001'
    end

    def cfe_url
      cfe_url_host + cfe_url_path
    end

    def legal_aid_application
      @legal_aid_application ||= @submission.legal_aid_application
    end

    def query_cfe_service
      raw_response = post_request
      raise_http_status_error(raw_response) unless raw_response.status == 200
      write_submission_history(raw_response)
      JSON.parse(raw_response.body)
    rescue StandardError => e
      raise_exception_error(e)
    end

    def post_request
      @conn.post do |request|
        request.url cfe_url_path
        request.headers['Content-Type'] = 'application/json'
        request.body = request_body
      end
    end

    def raise_http_status_error(raw_response)
      raise CFE::SubmissionError.new "HTTP status #{raw_response.status} returned from #{cfe_url}", raw_response.status
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
      raise CFE::SubmissionError, formatted_error_message(err)
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
