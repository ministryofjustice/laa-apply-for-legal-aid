module Providers
  class ShowExistingApplicationsController < ProviderBaseController
    legal_aid_application_not_required!

    def new
      @search_text = params[:search]
      @body = parsed_json_response["name"]
    end

  private

    def parsed_json_response
      JSON.parse(get_request.body)
    end

    def get_request
      conn.get
    end

    def conn
      @conn ||= Faraday.new(url:, headers:)
    end

    def url
      "https://swapi.dev/api/people/#{@search_text}"
    end

    def headers
      { "Content-Type" => "application/json" }
    end
  end
end
