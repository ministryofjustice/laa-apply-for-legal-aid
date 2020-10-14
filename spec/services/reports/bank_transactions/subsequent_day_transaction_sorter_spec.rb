require 'rails_helper'
require_relative 'mock_bank_transaction'

module Reports
  module BankTransactions
    RSpec.describe SubsequentDayTransactionSorter do
      subject { described_class.call(balance, unordered_transactions) }

      let(:balance) { 250.0 }

      context 'transactions have running balance' do
        context 'one transaction' do
          let(:unordered_transactions) { [MockBankTransaction.new(-33.43, 216.57)] }
          it 'returns the single transaction in an array' do
            expect(subject).to eq unordered_transactions
          end
        end

        context 'two transactions in the wrong order' do
          let(:unordered_transactions) { two_tx_in_wrong_order }
          it 'returns the two transaction sin the correct order' do
            results = subject
            expect(results.map(&:amount)).to eq [-33.43, 10.01]
            expect(results.map(&:running_balance)).to eq [216.57, 226.58]
          end
        end

        context 'two transactions in the right order' do
          let(:unordered_transactions) { two_tx_in_correct_order }
          it 'returns the two transaction sin the correct order' do
            expect(subject).to eq unordered_transactions
          end
        end

        context 'multiple transactions in the wrong order' do
          let(:unordered_transactions) { multiple_transactions_wrong_order }
          it 'sorts them into the correct order' do
            actual_results = subject.map { |tx| [tx.amount, tx.running_balance] }
            expected_results = multiple_transactions_correct_order.map { |tx| [tx.amount, tx.running_balance] }
            expect(actual_results).to eq expected_results
          end
        end
      end

      context 'transactions do  not have running balance' do
        let(:unordered_transactions) { transactions_without_balances }
        it 'returns the same transactions' do
          expect(subject).to eq unordered_transactions
        end
      end

      context 'erroneous transactions' do
        context 'running balance not present on all transactions' do
          let(:unordered_transactions) { transactions_with_and_without_balances }
          it 'returns the transactions with all balances set to nil' do
            result = subject
            expect(result.map(&:amount)).to eq unordered_transactions.map(&:amount)
            expect(result.map(&:running_balance)).to eq [nil, nil, nil]
          end
        end

        context 'records cannot be ordered' do
          let(:unordered_transactions) { transactions_with_unorderable_balances }
          it 'returns the array of transactions with all balancees set to nil' do
            result = subject
            expect(result.map(&:amount)).to eq unordered_transactions.map(&:amount)
            expect(result.map(&:running_balance).uniq).to eq [nil]
          end
        end

        context 'one record whose balance does not compute' do
          let(:unordered_transactions) { [MockBankTransaction.new(-33.43, 1216.57)] }
          it 'returns that transaction in an array with balance set to nil' do
            expect(subject.map(&:amount)).to eq [-33.43]
            expect(subject.map(&:running_balance)).to eq [nil]
          end
        end
      end

      def mock_transactions_from(data_items)
        data_items.map { |item| MockBankTransaction.new(item.first, item.last) }
      end

      def transactions_with_unorderable_balances
        mock_transactions_from(
          [
            [-88.99, 161.01],
            [-10, 151.01],
            [-10, 176.45],
            [67.72, 244.17]
          ]
        )
      end

      def transactions_without_balances
        mock_transactions_from(
          [
            [-33.66, nil],
            [-12.10, nil],
            [1399.25, nil]
          ]
        )
      end

      def transactions_with_and_without_balances
        mock_transactions_from(
          [
            [-33.66, 489.02],
            [-12.10, nil],
            [1399.25, 1876.17]
          ]
        )
      end

      def two_tx_in_wrong_order
        mock_transactions_from(
          [
            [10.01, 226.58],
            [-33.43, 216.57]
          ]
        )
      end

      def two_tx_in_correct_order
        mock_transactions_from(
          [
            [-33.43, 216.57],
            [10.01, 226.58]
          ]
        )
      end

      def multiple_transactions_correct_order
        mock_transactions_from(
          [
            [-88.99, 161.01],
            [-10, 151.01],
            [35.44, 186.45],
            [-10, 176.45],
            [67.72, 244.17]
          ]
        )
      end

      def multiple_transactions_wrong_order
        mock_transactions_from(
          [
            [-10, 151.01],
            [-88.99, 161.01],
            [67.72, 244.17],
            [35.44, 186.45],
            [-10, 176.45]
          ]
        )
      end
    end
  end
end
