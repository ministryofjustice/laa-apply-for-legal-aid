require 'rails_helper'

RSpec.describe BankTransactionPresenter do
  subject(:presenter) { described_class.new(transaction, remarks) }
  let(:account) { create :bank_account, account_type: 'SAVINGS' }
  let(:transaction) { create :bank_transaction, :uncategorised_credit_transaction, bank_account: account }
  let(:remarks) { [] }

  it { is_expected.to be_a BankTransactionPresenter }

  describe '.headers' do
    subject(:headers) { described_class.headers }

    it { is_expected.to be_a Array }
    it { expect(headers.count).to eq 14 }
  end

  describe '.present!' do
    subject(:present!) { described_class.present!(transaction, remarks) }

    it { is_expected.to be_a Array }
  end

  describe '#present' do
    subject(:present) { presenter.present }

    it { is_expected.to be_a Array }
  end

  describe 'transformative methods' do
    describe 'happened_at' do
      subject(:happened_at) { presenter.build_transaction_hash[:happened_at] }

      it { is_expected.to eq transaction.happened_at.strftime('%d/%b/%Y') }
    end

    describe 'amounts' do
      context 'when the bank transaction is a credit' do
        describe 'credit' do
          subject(:credit) { presenter.build_transaction_hash[:credit] }

          it { is_expected.to eq transaction.amount }
        end

        describe 'debit' do
          subject(:debit) { presenter.build_transaction_hash[:debit] }

          it { is_expected.to be nil }
        end
      end

      context 'when the bank transaction is a debit' do
        let(:transaction) { create :bank_transaction, :uncategorised_debit_transaction }

        describe 'credit' do
          subject(:credit) { presenter.build_transaction_hash[:credit] }

          it { is_expected.to be nil }
        end

        describe 'debit' do
          subject(:debit) { presenter.build_transaction_hash[:debit] }

          it { is_expected.to eq transaction.amount }
        end
      end
    end

    describe 'category' do
      subject(:category) { presenter.build_transaction_hash[:category] }

      context 'when the meta_data is empty' do
        it { is_expected.to be nil }
      end

      context 'when the transaction has been categorized' do
        let(:transaction) { create :bank_transaction, :benefits }

        it 'displays the transaction_type name' do
          expect(category).to eq 'Child Benefit'
        end
      end
    end

    describe 'flagged' do
      subject(:flagged) { presenter.build_transaction_hash[:flagged] }
      context 'when no remarks are passed from the CFE result' do
        it { is_expected.to be nil }
      end

      context 'when a single remark is passed from the CFE result as a symbol' do
        let(:remarks) { [:unknown_frequency] }

        it { is_expected.to eq 'Unknown frequency' }
      end

      context 'when multiple remarks are passed from the CFE result as strings' do
        let(:remarks) { %w[amount_variation unknown_frequency] }

        it { is_expected.to eq 'Amount variation, Unknown frequency' }
      end
    end

    describe 'balance_running_total' do
      subject(:balance_running_total) { presenter.build_transaction_hash[:balance_running_total] }
      context 'when there is a running balance value' do
        it { is_expected.to eq transaction.running_balance }
      end

      context 'when there is no running balance value' do
        before { transaction.running_balance = nil }
        it { is_expected.to eq 'Not available' }
      end
    end

    describe 'account_type' do
      subject(:account_type) { presenter.build_transaction_hash[:account_type] }
      context 'when the transaction is from a savings account' do
        it { is_expected.to eq 'Bank Savings' }
      end

      context 'when the transaction is from a current account' do
        let(:account) { create :bank_account, account_type: 'TRANSACTION' }
        it { is_expected.to eq 'Bank Current' }
      end
    end

    describe 'account_name' do
      subject(:account_name) { presenter.build_transaction_hash[:account_name] }
      it { is_expected.to eq account.bank_and_account_name }
    end

    describe 'sort_code' do
      subject(:sort_code) { presenter.build_transaction_hash[:sort_code] }

      it { is_expected.to eq "#{account.sort_code}\t" }
    end

    describe 'account_number' do
      subject(:account_number) { presenter.build_transaction_hash[:account_number] }

      it { is_expected.to eq account.account_number }
    end
  end
end
