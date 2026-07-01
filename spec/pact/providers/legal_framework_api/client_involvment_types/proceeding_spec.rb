require "rails_helper"

RSpec.describe "Client Involvement Types by proceeding contract", :pact do
  include_context "with legal framework api consumer pact"

  describe LegalFramework::ClientInvolvementTypes::Proceeding do
    let(:interaction) do
      new_interaction
        .given("client involvement types exist for the given proceeding code DA001")
        .upon_receiving("a request for client involvement types for proceeding code DA001")
        .with_request(
          method: :get,
          path: "/client_involvement_types/DA001",
        )
        .will_respond_with(
          status: 200,
          headers: {
            "Content-Type" => "application/json",
          },
          body: expected_body,
        )
    end

    let(:expected_body) do
      {
        success: true,
        client_involvement_type: [
          {
            ccms_code: "A",
            description: "Applicant/claimant/petitioner",
          },
          {
            ccms_code: "D",
            description: "Defendant/respondent",
          },
          {
            ccms_code: "W",
            description: "Subject of proceedings (child)",
          },
          {
            ccms_code: "I",
            description: "Intervenor",
          },
          {
            ccms_code: "Z",
            description: "Joined party",
          },
        ],
      }.to_json
    end

    it "executes the pact test without errors", skip: "failing upstream" do
      interaction.execute do |mock_server|
        allow(Rails.configuration.x).to receive(:legal_framework_api_host).and_return(mock_server.url)

        client = described_class.new("DA001")
        result = client.call

        expect(result)
          .to contain_exactly(
            an_object_having_attributes(
              ccms_code: "A",
              description: "Applicant, claimant or petitioner",
            ),
            an_object_having_attributes(
              ccms_code: "D",
              description: "Defendant or respondent",
            ),
            an_object_having_attributes(
              ccms_code: "W",
              description: "A child subject of the proceeding",
            ),
            an_object_having_attributes(
              ccms_code: "I",
              description: "Intervenor",
            ),
            an_object_having_attributes(
              ccms_code: "Z",
              description: "Joined party",
            ),
          )
      end
    end
  end
end
