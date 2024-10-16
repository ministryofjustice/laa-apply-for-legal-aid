require "rails_helper"

RSpec.describe BankAccount do
  describe "#account_type_label" do
    let(:not_defined_account_type) { "LIFE_ISA" }

    it "maps the account_type from TrueLayer" do
      described_class::ACCOUNT_TYPE_LABELS.each do |key, val|
        bank_account = create(:bank_account, account_type: key)
        result = bank_account.account_type_label
        expect(result).to eq(val), "account_type #{key} should be mapped to #{val}, got #{result}"
      end
    end

    it "defaults to TrueLayer account_type if not defined in the mapping hash" do
      bank_account = create(:bank_account, account_type: not_defined_account_type)
      expect(bank_account.account_type_label).to eq(not_defined_account_type)
    end

    context "with savings type" do
      it "returns Bank Savings" do
        bank_account = create(:bank_account, account_type: "SAVINGS")
        expect(bank_account.account_type_label).to eq("Bank Savings")
      end
    end

    context "with transactions type" do
      it "returns Bank Current" do
        bank_account = create(:bank_account, account_type: "TRANSACTION")
        expect(bank_account.account_type_label).to eq("Bank Current")
      end
    end
  end

  describe "#holder_type" do
    it "returns the correct account holder" do
      bank_account = create(:bank_account)
      expect(bank_account.holder_type).to eq "Client Sole"
    end
  end

  describe "#display_name" do
    it "returns the correct display name" do
      bank_account = create(:bank_account)
      bank_account.bank_provider.name = "Test Bank"
      bank_account.account_number = "123456789"
      expect(bank_account.display_name).to eq "Test Bank Acct 123456789"
    end
  end

  describe "#has_benefits?" do
    let(:bank_account) { create(:bank_account) }

    it "returns true if benefits present" do
      create(:bank_transaction, :benefits, bank_account:)
      expect(bank_account.has_benefits?).to be true
    end

    it "returns false if benefits not present" do
      create(:bank_transaction, :friends_or_family, bank_account:)
      expect(bank_account.has_benefits?).to be false
    end
  end

  describe "#has_tax_credits?" do
    let(:bank_account) { create(:bank_account) }

    it "returns false if tax credits not present" do
      create(:bank_transaction, :benefits, bank_account:)
      expect(bank_account.has_tax_credits?).to be false
    end

    it "returns false if meta_data for all transactions is nil" do
      create(:bank_transaction, :uncategorised_debit_transaction, meta_data: nil, bank_account:)
      expect(bank_account.has_tax_credits?).to be false
    end

    it "returns true if tax credits are present" do
      create(:bank_transaction, :with_meta_tax, bank_account:)
      expect(bank_account.has_tax_credits?).to be true
    end
  end

  describe "#latest_balance" do
    let(:bank_account) { create(:bank_account) }

    context "when transactions exist" do
      before { create_transactions }

      it "returns the running balance of the latest transaction" do
        expect(bank_account.latest_balance).to eq 415.26
      end
    end

    context "with no bank transactions" do
      it "returns the balance from the bank account record" do
        expect(bank_account.bank_transactions.size).to eq 0
        expect(bank_account.latest_balance).to eq bank_account.balance
      end
    end

    def create_transactions
      create(:bank_transaction, bank_account:, happened_at: 2.days.ago, running_balance: 300.44)
      create(:bank_transaction, bank_account:, happened_at: 2.days.ago, running_balance: 400.44)
      create(:bank_transaction, bank_account:, happened_at: Date.current, running_balance: 415.26)
    end
  end

  describe "standard values" do
    subject(:bank_account) { create(:bank_account) }

    it { expect(bank_account.has_wages?).to be false }
    it { expect(bank_account.ccms_instance_name(1)).to eq "the bank account1" }
  end
end
