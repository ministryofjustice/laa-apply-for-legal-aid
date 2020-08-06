module RequestHelpers
  def self.included(base)
    super
    base.include(JsonHelpers)
    base.include(ResponseHelpers)
  end

  module JsonHelpers
    def json_headers
      {
        'ACCEPT' => 'application/json',
        'HTTP_ACCEPT' => 'application/json',
        'Content-Type' => 'application/json'
      }
    end

    def json
      JSON.parse(response.body)
    end
  end

  module ResponseHelpers
    def unescaped_response_body
      CGI.unescapeHTML(response.body)
    end
  end
end
