require "rails_helper"

RSpec.describe CFECivil::Components::Properties do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

  context "when there are no properties" do
    it "returns the expected JSON block" do
      expect(call).to eq({
        properties: {
          main_home: {
            value: 0.0,
            outstanding_mortgage: 0.0,
            percentage_owned: 0.0,
            shared_with_housing_assoc: false,
          },
          additional_properties: [
            {
              value: 0.0,
              outstanding_mortgage: 0.0,
              percentage_owned: 0.0,
              shared_with_housing_assoc: false,
            },
          ],
        },
      }.to_json)
    end
  end

  context "when there is a property" do
    let(:legal_aid_application) do
      create(:legal_aid_application,
             :with_applicant,
             property_value: 50_000,
             outstanding_mortgage_amount: 10_000,
             percentage_home: 45.67,
             shared_ownership: false)
    end

    it "returns the expected JSON block" do
      expect(call).to eq({
        properties: {
          main_home: {
            value: 50_000.0,
            outstanding_mortgage: 10_000.0,
            percentage_owned: 45.67,
            shared_with_housing_assoc: false,
          },
          additional_properties: [
            {
              value: 0.0,
              outstanding_mortgage: 0.0,
              percentage_owned: 0.0,
              shared_with_housing_assoc: false,
            },
          ],
        },
      }.to_json)
    end
  end
end
