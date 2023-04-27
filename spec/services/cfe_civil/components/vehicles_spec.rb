require "rails_helper"

RSpec.describe CFECivil::Components::Vehicles do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

  context "when there are no vehicles" do
    it "returns the expected JSON block" do
      expect(call).to eq({
        vehicles: [],
      }.to_json)
    end
  end

  context "when a vehicle has been added" do
    before do
      create(:vehicle,
             legal_aid_application:,
             estimated_value: 2345.0,
             payment_remaining: 321.0,
             purchased_on: Date.new(2020, 5, 18),
             used_regularly: true)
    end

    it "returns the expected JSON block" do
      expect(call).to eq({
        vehicles: [
          value: 2345.0,
          loan_amount_outstanding: 321.0,
          date_of_purchase: "2020-05-18",
          in_regular_use: true,
        ],
      }.to_json)
    end
  end
end
