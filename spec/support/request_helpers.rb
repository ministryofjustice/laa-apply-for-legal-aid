module RequestHelpers
  def self.included(base)
    base.include(JsonHelpers)
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
end
