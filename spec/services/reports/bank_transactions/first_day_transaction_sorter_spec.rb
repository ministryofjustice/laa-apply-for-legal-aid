require 'rails_helper'
require_relative 'mock_bank_transaction'

module Reports
  module BankTransactions
    RSpec.describe FirstDayTransactionSorter do
      subject { described_class.call(unsorted_transactions) }

      context 'with running_balance' do
        context 'one transaction' do
          let(:unsorted_transactions) { [MockBankTransaction.new(-33.56, 377.66)] }

          it 'returns the same transaction as an array' do
            expect(subject).to eq unsorted_transactions
          end
        end

        context 'two transactions already in correct order' do
          let(:unsorted_transactions) do
            [
              MockBankTransaction.new(360.66, 1439.57),
              MockBankTransaction.new(-130, 1309.57)
            ]
          end
          it 'returns the same transactions in an array' do
            expect(subject).to eq unsorted_transactions
          end
        end

        context 'multiple transactions in random order' do
          let(:unsorted_transactions) { randomly_ordered_transactions }
          it 'returns them in sorted order' do
            results = subject
            expect(results.map { |tx| [tx.amount.to_f, tx.running_balance.to_f] }).to eq running_balance_orderd_transactions
          end
        end
      end

      context 'without running_balance' do
        context 'one transaction' do
          let(:unsorted_transactions) { [MockBankTransaction.new(54.6, nil)] }
          it 'returns the original transactions as an array' do
            expect(subject).to eq unsorted_transactions
          end
        end

        context 'multiple transactions' do
          let(:unsorted_transactions) do
            [
              MockBankTransaction.new(54.6, nil),
              MockBankTransaction.new(22.46, nil),
              MockBankTransaction.new(-266.55, nil)
            ]
          end

          it 'returns the original transactions as an array' do
            expect(subject).to eq unsorted_transactions
          end
        end
      end

      context 'invalid data' do
        context 'running_balances do not compute' do
          let(:unsorted_transactions) { erroneous_transactions }
          it 'sends a message to Sentry' do
            error = double OrderingError
            message = "No sequence could be found for bank transactions with ids: #{unsorted_transactions.map(&:id)}"
            expect(OrderingError).to receive(:new).with(message).and_return(error)
            expect(Raven).to receive(:capture_exception).with(error)
            subject
          end

          it 'marks all transactions with nil running_balances in the csv' do
            tx_ids = unsorted_transactions.map(&:id)
            results = subject
            expect(results.map(&:id)).to eq tx_ids
            expect(results.map(&:running_balance).uniq).to eq [nil]
          end
        end

        context 'mixture of running_balance present and running_balance absent' do
          let(:unsorted_transactions) { transactions_with_and_without_running_balances }
          it 'captures an error and sends to Sentry' do
            error = double OrderingError
            message = "Not all bank transactions have running_balances: ids: #{unsorted_transactions.map(&:id).join(', ')}"
            expect(OrderingError).to receive(:new).with(message).and_return(error)
            expect(Raven).to receive(:capture_exception).with(error)
            subject
          end

          it 'returns the list of transactions in the same order with running_balances set to nil' do
            tx_ids = unsorted_transactions.map(&:id)
            results = subject
            expect(results.map(&:id)).to eq tx_ids
            expect(results.map(&:running_balance).uniq).to eq [nil]
          end
        end
      end

      def mock_transactions_from(data_items)
        data_items.map { |item| MockBankTransaction.new(item.first, item.last) }
      end

      def randomly_ordered_transactions
        mock_transactions_from(
          [
            [3.3, 1187.97],
            [10, 1197.97],
            [-129.06, 1068.91],
            [10, 1078.91],
            [360.66, 1439.57],
            [-130, 1309.57],
            [-479.34, 830.23],
            [-130, 700.23]
          ]
        )
      end

      def running_balance_orderd_transactions
        [
          [3.3, 1187.97],
          [10, 1197.97],
          [-129.06, 1068.91],
          [10, 1078.91],
          [360.66, 1439.57],
          [-130, 1309.57],
          [-479.34, 830.23],
          [-130, 700.23]
        ]
      end

      def erroneous_transactions
        mock_transactions_from(
          [
            [3.3, 1187.97],
            [-129.06, 1068.91],
            [10, 1078.91],
            [-130, 1309.57],
            [-130, 700.23]
          ]
        )
      end

      def transactions_with_and_without_running_balances
        mock_transactions_from(
          [
            [3.3, 1187.97],
            [10, nil],
            [-129.06, 1068.91]
          ]
        )
      end
    end
  end
end
