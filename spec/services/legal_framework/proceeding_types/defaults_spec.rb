require "rails_helper"

RSpec.describe LegalFramework::ProceedingTypes::Defaults, :vcr do
  subject(:defaults) { described_class }

  let(:uri) { "#{Rails.configuration.x.legal_framework_api_host}/proceeding_types_defaults" }

  describe ".call" do
    subject(:call) { defaults.call(proceeding, false) }

    before { call }

    let(:proceeding) { create(:proceeding, :da001, :without_df_date) }
    let(:expected_json) do
      {
        success: true,
        requested_params: {
          proceeding_type_ccms_code: "DA001",
          delegated_functions_used: false,
          client_involvement_type: "A",
        },
        default_level_of_service: {
          level: 3,
          name: "Full Representation",
          stage: 8,
        },
        default_scope: {
          code: "AA019",
          meaning: "Injunction FLA-to final hearing",
          description: "As to proceedings under Part IV Family Law Act 1996 limited to all steps up to and including obtaining and serving a final order and in the event of breach leading to the exercise of a power of arrest to representation on the consideration of the breach by the court (but excluding applying for a warrant of arrest, if not attached, and representation in contempt proceedings).",
          additional_params: [],
        },
      }
    end

    it "returns the expected json" do
      expect(JSON.parse(call)).to match_json_expression(expected_json)
    end
  end
end
