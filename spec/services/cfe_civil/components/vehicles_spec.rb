require "rails_helper"

RSpec.describe CFECivil::Components::Vehicles do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner) }

  context "when there are no vehicles" do
    it "returns the expected JSON block" do
      expect(call).to eq({
        vehicles: [],
      }.to_json)
    end
  end

  context "when vehicles have been added for both client and partner" do
    before do
      create(:vehicle,
             legal_aid_application:,
             estimated_value: 2345.0,
             payment_remaining: 321.0,
             more_than_three_years_old: true,
             used_regularly: true,
             owner: "client")
      create(:vehicle,
             legal_aid_application:,
             estimated_value: 3254.0,
             payment_remaining: 123.0,
             more_than_three_years_old: true,
             used_regularly: true,
             owner: "partner")
    end

    context "and no owner is specified" do
      it "returns the expected JSON block with only the applicant vehicle" do
        expect(call).to eq({
          vehicles: [
            value: 2345.0,
            loan_amount_outstanding: 321.0,
            date_of_purchase: 4.years.ago.to_date,
            in_regular_use: true,
          ],
        }.to_json)
      end
    end

    context "and the partner is set as owner" do
      subject(:call) { described_class.call(legal_aid_application, "partner") }

      it "returns the expected JSON block with only the partner vehicle" do
        expect(call).to eq({
          vehicles: [
            value: 3254.0,
            loan_amount_outstanding: 123.0,
            date_of_purchase: 4.years.ago.to_date,
            in_regular_use: true,
          ],
        }.to_json)
      end
    end
  end
end
