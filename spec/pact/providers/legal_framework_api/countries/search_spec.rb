require "rails_helper"

RSpec.describe "Search Countries contract", :pact do
  include_context "with legal framework api consumer pact"

  describe "countries.js" do
    let(:interaction) do
      new_interaction
        .given("searchable countries exist")
        .upon_receiving("a request to search for a country")
        .with_request(
          method: :post,
          path: "/countries/search",
          body: {
            search_term: "antarc",
          },
        )
        .will_respond_with(
          status: 200,
          headers: {
            "Content-Type" => "application/json",
          },
          body: expected_body,
        )
    end

    # see https://github.com/pact-foundation/pact-ruby#matchers
    let(:expected_body) do
      {
        success: match_any_boolean(true),
        data: match_each(
          {

            description: match_any_string("Antarctica"),
            code: match_regex(/^[A-Z]*$/, "ATA"),
            description_headline: match_any_string("<mark>Antarctica</mark>"),
          },
        ),
      }
    end

    let(:client_klass) do
      Class.new do
        def self.call(search_term)
          new(search_term).call
        end

        def initialize(search_term)
          @search_term = search_term
        end

        def call
          response = post_request
          JSON.parse(response.body, symbolize_names: true)
        end

      private

        def post_request
          conn.post do |request|
            request.url url_path
            request.headers["Content-Type"] = "application/json"
            request.body = request_body
          end
        end

        def conn
          @conn ||= Faraday.new(url: host, headers:)
        end

        def host
          Rails.configuration.x.legal_framework_api_host
        end

        def headers
          {
            "Content-Type" => "application/json",
          }
        end

        def url_path
          "countries/search"
        end

        def request_body
          {
            search_term: @search_term,
          }.to_json
        end
      end
    end

    it "executes the pact test without errors" do
      interaction.execute do |mock_server|
        allow(Rails.configuration.x).to receive(:legal_framework_api_host).and_return(mock_server.url)

        # Do roughly what the countries.js does but in ruby to get the data from the api and check it matches the expected body
        result = client_klass.call("antarc")

        expect(result).not_to be_empty

        expect(result[:data].first)
        .to match(
          code: a_string_matching(/^[A-Z]*$/),
          description: a_string_matching(/.+/),
          description_headline: a_string_matching(/<mark>.*<\/mark>.*/),
        )
      end
    end
  end
end
