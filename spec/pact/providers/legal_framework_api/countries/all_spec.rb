require "rails_helper"

RSpec.describe "All Countries contract", :pact do
  include_context "with legal framework api consumer pact"

  describe LegalFramework::NonUkHomeAddresses::All do
    let(:interaction) do
      new_interaction
        .given("countries exist")
        .upon_receiving("a request for all countries")
        .with_request(
          method: :get,
          path: "/countries/all",
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
      match_each(
        {
          code: match_regex(/^[A-Z]*$/, "AUT"),
          description: match_any_string("Austria"),
        },
      )
    end

    it "executes the pact test without errors" do
      interaction.execute do |mock_server|
        allow(Rails.configuration.x).to receive(:legal_framework_api_host).and_return(mock_server.url)

        client = described_class.new
        result = client.call

        expect(result).not_to be_empty
        expect(result.first).to have_attributes(code: a_string_matching(/^[A-Z]*$/), description: a_string_matching(/.+/))
      end
    end
  end
end
