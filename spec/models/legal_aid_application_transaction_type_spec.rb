require "rails_helper"

RSpec.describe LegalAidApplicationTransactionType, type: :model do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:credit_transaction_type) { create(:transaction_type, :credit_with_standard_name) }
  let(:debit_transaction_type) { create(:transaction_type, :debit_with_standard_name) }

  describe ".credits" do
    subject(:credits) { described_class.credits }

    let!(:a_credit) do
      create(
        :legal_aid_application_transaction_type,
        legal_aid_application:,
        transaction_type: credit_transaction_type,
      )
    end

    before do
      create(
        :legal_aid_application_transaction_type,
        legal_aid_application:,
        transaction_type: debit_transaction_type,
      )
    end

    it "returns credits only" do
      expect(credits).to contain_exactly(a_credit)
    end
  end

  describe ".debits" do
    subject(:debits) { described_class.debits }

    let!(:a_debit) do
      create(
        :legal_aid_application_transaction_type,
        legal_aid_application:,
        transaction_type: debit_transaction_type,
      )
    end

    before do
      create(
        :legal_aid_application_transaction_type,
        legal_aid_application:,
        transaction_type: credit_transaction_type,
      )
    end

    it "returns debits only" do
      expect(debits).to contain_exactly(a_debit)
    end
  end
end
