require "rails_helper"

RSpec.describe CFECivil::Components::RegularTransactions do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner) }

  context "when there are no regular transactions" do
    it "returns the expected, empty, JSON block" do
      expect(call).to eq({
        regular_transactions: [],
      }.to_json)
    end
  end

  context "when there are regular transactions for both Applicant and Partner" do
    before do
      applicant = legal_aid_application.applicant
      partner = legal_aid_application.partner
      create(:regular_transaction,
             :maintenance_out,
             legal_aid_application:,
             amount: 222.22,
             frequency: "monthly",
             owner_type: applicant.class,
             owner_id: applicant.id)
      create(:regular_transaction,
             :maintenance_in,
             legal_aid_application:,
             amount: 111.11,
             frequency: "monthly",
             owner_type: applicant.class,
             owner_id: applicant.id)
      create(:regular_transaction,
             :friends_or_family,
             legal_aid_application:,
             amount: 501.00,
             frequency: "monthly",
             owner_type: partner.class,
             owner_id: partner.id)
    end

    context "and no owner is specified" do
      it "returns the expected JSON block" do
        expect(JSON.parse(call)).to match_json_expression({
          regular_transactions: [
            {
              category: "maintenance_in",
              operation: "credit",
              amount: 111.11,
              frequency: "monthly",
            },
            {
              category: "maintenance_out",
              operation: "debit",
              amount: 222.22,
              frequency: "monthly",
            },
          ],
        })
      end
    end

    context "and partner is specified as owner type" do
      subject(:call) { described_class.call(legal_aid_application, "Partner") }

      it "returns the expected JSON block just for the partner" do
        expect(JSON.parse(call)).to match_json_expression({
          regular_transactions: [
            {
              category: "friends_or_family",
              operation: "credit",
              amount: 501.00,
              frequency: "monthly",
            },
          ],
        })
      end
    end
  end
end
