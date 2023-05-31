require "rails_helper"

RSpec.describe RegularTransaction do
  describe "#validate" do
    context "when amount is blank" do
      it "is invalid" do
        regular_transaction = build_stubbed(:regular_transaction, amount: nil)

        expect(regular_transaction).to be_invalid
        expect(regular_transaction.errors).to be_added(
          :amount,
          :not_a_number,
          value: "",
        )
      end
    end

    context "when amount is invalid" do
      it "is invalid" do
        regular_transaction = build_stubbed(:regular_transaction, amount: "-1000")

        expect(regular_transaction).to be_invalid
        expect(regular_transaction.errors).to be_added(
          :amount,
          :greater_than,
          value: -1000,
          count: 0,
        )
      end
    end

    context "when frequency is blank" do
      it "is invalid" do
        regular_transaction = build_stubbed(:regular_transaction, frequency: nil)

        expect(regular_transaction).to be_invalid
        expect(regular_transaction.errors).to be_added(
          :frequency,
          :inclusion,
          value: nil,
        )
      end
    end

    context "when frequency is invalid" do
      it "is invalid" do
        regular_transaction = build_stubbed(:regular_transaction, frequency: "invalid")

        expect(regular_transaction).to be_invalid
        expect(regular_transaction.errors).to be_added(
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
          frequency: "weekly",
        )

        expect(record).to be_valid
      end
    end
  end

  describe ".credits" do
    it "returns payments where the transaction type is a credit" do
      credit = create(:transaction_type, :benefits)
      debit = create(:transaction_type, :child_care)
      credit_payment = create(:regular_transaction, transaction_type: credit)
      _debit_payment = create(:regular_transaction, transaction_type: debit)

      records = described_class.credits

      expect(records).to contain_exactly(credit_payment)
    end
  end

  describe ".debits" do
    it "returns payments where the transaction type is a debit" do
      credit = create(:transaction_type, :benefits)
      debit = create(:transaction_type, :child_care)
      _credit_payment = create(:regular_transaction, transaction_type: credit)
      debit_payment = create(:regular_transaction, transaction_type: debit)

      records = described_class.debits

      expect(records).to contain_exactly(debit_payment)
    end
  end

  describe ".frequencies_for" do
    context "when transaction type is benefits" do
      it "does not include monthly in the frequencies" do
        benefits = create(:transaction_type, :benefits)

        frequencies = described_class.frequencies_for(benefits)

        expect(frequencies).to match(%w[weekly two_weekly four_weekly])
      end
    end

    context "when transaction type is not benefits" do
      it "includes monthly in the frequencies" do
        child_care = create(:transaction_type, :child_care)

        frequencies = described_class.frequencies_for(child_care)

        expect(frequencies).to match(%w[weekly two_weekly four_weekly monthly three_monthly])
      end
    end
  end
end
