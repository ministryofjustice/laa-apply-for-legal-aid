require "rails_helper"

RSpec.describe Banking::BankTransactionsTrimmer do
  describe ".call" do
    subject(:bank_transaction_trimmer) { described_class.call(application) }

    let(:application) { create(:legal_aid_application, :with_applicant) }
    let(:applicant) { application.applicant }
    let(:bank) { create(:bank_provider, applicant:) }
    let(:acct1) { create(:bank_account, bank_provider: bank, balance: 733.44) }
    let(:acct2) { create(:bank_account, bank_provider: bank, balance: 2.36) }

    before do
      populate_all_transactions
      allow(application).to receive_messages(transaction_period_start_on: period_start, transaction_period_finish_on: period_end)
    end

    context "when all transactions are within the transaction period" do
      let(:period_start) { Date.parse("2020-10-05").beginning_of_day }
      let(:period_end) { Date.parse("2021-01-07").beginning_of_day }

      it "does not delete any transactions" do
        expect { bank_transaction_trimmer }.not_to change(BankTransaction, :count)
      end
    end

    context "when some transactions are after the end of the transaction period" do
      let(:period_start) { Date.parse("2020-10-06").beginning_of_day }
      let(:period_end) { Date.parse("2021-01-04").beginning_of_day }

      it "has deleted records happened on after 4/1/2021" do
        expect { bank_transaction_trimmer }.to change(BankTransaction, :count).by(-4)
        expect(application.bank_transactions.pluck(:happened_at)).not_to include("2021-01-05T01:00:00")
        expect(application.bank_transactions.pluck(:happened_at)).not_to include("2021-01-06T01:00:00")
      end
    end
  end

  def populate_all_transactions
    populate_transactions(acct1, acct1_tx_seed_data)
    populate_transactions(acct2, acct2_tx_seed_data)
  end

  def populate_transactions(bank_account, seed_data)
    seed_data.each do |row|
      create(:bank_transaction,
             bank_account:,
             happened_at: Time.zone.parse(row[0]),
             created_at: Time.zone.parse(row[1]),
             operation: row[2],
             amount: row[3])
    end
  end

  def acct1_tx_seed_data
    # happened_at, created_at, operation, amount
    [
      ["2021-01-05T01:00:00",  "2021-01-25T10:05:43", :credit, 98.66],
      ["2021-01-05T01:00:00",  "2021-01-25T10:05:42", :debit, -36.27],
      ["2021-01-03T01:00:00",  "2021-01-25T10:05:43", :debit, -75.22],
      ["2021-01-02T01:00:00",  "2021-01-25T10:05:43", :credit, -93.66],
    ]
  end

  def acct2_tx_seed_data
    # happened_at, created_at, operation, amount
    [
      ["2021-01-06T01:00:00",  "2021-01-25T10:05:43", :credit, 98.66],
      ["2021-01-05T01:00:00",  "2021-01-25T10:05:42", :debit, -36.27],
      ["2021-01-03T01:00:00",  "2021-01-25T10:05:43", :debit, -75.22],
      ["2021-01-02T01:00:00",  "2021-01-25T10:05:43", :credit, -93.66],
    ]
  end
end
