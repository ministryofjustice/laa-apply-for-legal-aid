module CFE
  class BaseConnector
    CFE_URL = 'http://localhost:3001'.freeze



    private

    def post_request
      begin
        raw_response = @conn.post do |request|
          request.url '/assessments'
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
  end
end
