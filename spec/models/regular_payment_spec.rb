require "rails_helper"

RSpec.describe RegularPayment, type: :model do
  describe "validations" do
    context "when amount is blank" do
      it "is invalid" do
        regular_payment = build_stubbed(:regular_payment, amount: nil)

        expect(regular_payment).to be_invalid
        expect(regular_payment.errors).to be_added(
          :amount,
          :not_a_number,
          value: "",
        )
      end
    end

    context "when amount is invalid" do
      it "is invalid" do
        regular_payment = build_stubbed(:regular_payment, amount: "-1000")

        expect(regular_payment).to be_invalid
        expect(regular_payment.errors).to be_added(
          :amount,
          :greater_than,
          value: -1000,
          count: 0,
        )
      end
    end

    context "when frequency is blank" do
      it "is invalid" do
        regular_payment = build_stubbed(:regular_payment, frequency: nil)

        expect(regular_payment).to be_invalid
        expect(regular_payment.errors).to be_added(
          :frequency,
          :inclusion,
          value: nil,
        )
      end
    end

    context "when frequency is invalid" do
      it "is invalid" do
        regular_payment = build_stubbed(:regular_payment, frequency: "invalid")

        expect(regular_payment).to be_invalid
        expect(regular_payment.errors).to be_added(
          :frequency,
          :inclusion,
          value: "invalid",
        )
      end
    end

    context "when correct attributes are provided" do
      it "is valid" do
        legal_aid_application = build_stubbed(:legal_aid_application)
        benefits = build_stubbed(:transaction_type, :benefits)

        record = described_class.new(
          legal_aid_application:,
          transaction_type: benefits,
          amount: "1500.50",
          frequency: "monthly",
        )

        expect(record).to be_valid
      end
    end
  end

  describe ".credits" do
    it "returns payments where the transaction type is a credit" do
      credit = create(:transaction_type, :benefits)
      debit = create(:transaction_type, :child_care)
      credit_payment = create(:regular_payment, transaction_type: credit)
      _debit_payment = create(:regular_payment, transaction_type: debit)

      records = described_class.credits

      expect(records).to contain_exactly(credit_payment)
    end
  end

  describe ".debits" do
    it "returns payments where the transaction type is a debit" do
      credit = create(:transaction_type, :benefits)
      debit = create(:transaction_type, :child_care)
      _credit_payment = create(:regular_payment, transaction_type: credit)
      debit_payment = create(:regular_payment, transaction_type: debit)

      records = described_class.debits

      expect(records).to contain_exactly(debit_payment)
    end
  end
end
