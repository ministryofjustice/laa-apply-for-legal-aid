require "rails_helper"

RSpec.describe CFECivil::Components::ProceedingTypes do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings) }

  it "returns the expected JSON block" do
    expect(call).to eq({
      proceeding_types: [
        { ccms_code: "DA001", client_involvement_type: "A" },
      ],
    }.to_json)
  end
end
