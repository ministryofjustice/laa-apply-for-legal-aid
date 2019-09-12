module CFE
  class BaseService

    def self.call(assessment)
      new(assessment).call
    end

    def initialize(assessment)
      @assessment = assessment
      @conn = Faraday.new(url: cfe_url_host)
    end

    def call
      @response = post_request
      process_response
    end

    private

    def cfe_url_host
      'http://localhost:3001'
    end

    def legal_aid_application
      @legal_aid_application ||= @assessment.legal_aid_application
    end

    def post_request
      begin
        raw_response = @conn.post do |request|
          request.url cfe_url_path
          request.headers['Content-Type'] = 'application/json'
          request.body = request_body
        end
        JSON.parse(raw_response.body)
      rescue => err
        {
          'success' => false,
          'errors' => "#{err.class} #{err.message}"
        }
      end
    end

    def process_response
      @response['success'] ? process_successful_response : process_error_response
    end

    def process_error_response
      puts ">>>>>>>>> ERROR #{__FILE__}:#{__LINE__} <<<<<<<<<<\n"
      raise SubmissionError.new 'XXXXX'
    end
  end
end
