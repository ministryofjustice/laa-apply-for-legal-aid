require 'rails_helper'

module Reports
  module BankTransactions
    RSpec.describe BankTransactionSorter do
      before { setup_bank_transactions }

      let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
      let!(:bank1) { create :bank_provider, applicant: legal_aid_application.applicant }
      let!(:bank2) { create :bank_provider, applicant: legal_aid_application.applicant }
      let!(:acct1) { create :bank_account, bank_provider: bank1, name: 'Bank Account 1' }
      let!(:acct2) { create :bank_account, bank_provider: bank1, name: 'Bank Account 2' }
      let!(:acct3) { create :bank_account, bank_provider: bank2, name: 'Bank Account 3' }
      let(:fixtures) { Rails.root.join('spec', 'fixtures', 'files', 'bank_transaction_sorting', 'sorted_bank_transactions.csv') }

      describe '.call' do
        it 'sorts using balance within date within bank account' do
          sorted_transactions = described_class.call(legal_aid_application)
          summary = sorted_transactions.map do |tx|
            [tx.bank_account.name, tx.happened_at.in_time_zone.strftime('%F %T'), tx.amount.to_f, tx.running_balance&.to_f]
          end
          expect(summary).to eq expected_results
        end
      end

      def setup_bank_transactions
        array_of_lines = CSV.read(fixtures)
        array_of_lines.shift
        array_of_lines.shuffle.each { |line| create_bank_transaction(line) }
      end

      def create_bank_transaction(line)
        account_name, date_string, amount, balance = line

        create :bank_transaction,
               bank_account: __send__(account_name.to_sym),
               operation: amount.to_f < 0 ? 'debit' : 'credit',
               amount: amount,
               running_balance: balance,
               happened_at: Date.parse(date_string),
               currency: 'GBP'
      end

      def expected_results
        results = []
        array_of_lines = CSV.read(fixtures)
        array_of_lines.shift
        array_of_lines.each do |line|
          account_symbol, date_string, amount, balance = line
          account_name = __send__(account_symbol.to_sym).name
          date = Date.parse(date_string)
          results << [account_name, date.in_time_zone.strftime('%F %T'), amount.to_f, balance.nil? ? nil : balance.to_f]
        end
        results
      end
    end
  end
end
