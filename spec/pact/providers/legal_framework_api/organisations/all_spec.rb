require "rails_helper"

RSpec.describe "All organisations contract", :pact do
  include_context "with legal framework api consumer pact"

  describe LegalFramework::Organisations::All do
    let(:interaction) do
      new_interaction
        .given("organisations exist")
        .upon_receiving("a request for all organisations")
        .with_request(
          method: :get,
          path: "/organisation_searches/all",
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
          name: match_any_string("Amber Valley Borough Council"),
          ccms_opponent_id: match_regex(/^\d+$/, "280360"),
          ccms_type_code: match_regex(/^[A-Z]*$/, "LA"),
          ccms_type_text: match_any_string("Local Authority"),
        },
      )
    end

    it "executes the pact test without errors" do
      interaction.execute do |mock_server|
        allow(Rails.configuration.x).to receive(:legal_framework_api_host).and_return(mock_server.url)

        client = described_class.new
        result = client.call

        expect(result).not_to be_empty
        expect(result.first)
          .to have_attributes(
            name: a_string_matching(/.+/),
            ccms_opponent_id: a_string_matching(/^\d+$/),
            ccms_type_code: a_string_matching(/^[A-Z]*$/),
            ccms_type_text: a_string_matching(/.+/),
          )
      end
    end
  end
end
