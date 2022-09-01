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

  describe ".after_commit" do
    let(:instance) do
      create(:legal_aid_application_transaction_type,
             legal_aid_application:,
             transaction_type: credit_transaction_type)
    end

    before do
      create(:legal_aid_application_transaction_type,
             legal_aid_application:,
             transaction_type: debit_transaction_type)

      legal_aid_application.cash_transactions.create!(transaction_type_id: credit_transaction_type.id, amount: 101, month_number: 1, transaction_date: Time.zone.now.to_date)
      legal_aid_application.cash_transactions.create!(transaction_type_id: debit_transaction_type.id, amount: 103, month_number: 3, transaction_date: 2.months.ago)
    end

    context "when destroying object instance" do
      let(:action) { instance.destroy! }

      it "deletes related cash transaction" do
        expect { action }.to change(legal_aid_application.cash_transactions, :count).by(-1)
        transaction_types = legal_aid_application.cash_transactions.map(&:transaction_type)
        expect(transaction_types).not_to include(credit_transaction_type)
      end
    end

    context "when updating object instance" do
      let(:action) { instance.update!(updated_at: Time.zone.now) }

      it "does not delete cash transactions" do
        expect { action }.not_to change(legal_aid_application.cash_transactions, :count)
        transaction_types = legal_aid_application.cash_transactions.map(&:transaction_type)
        expect(transaction_types).to include(credit_transaction_type, debit_transaction_type)
      end
    end
  end
end
