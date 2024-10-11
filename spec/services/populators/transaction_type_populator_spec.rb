require "rails_helper"

module Populators
  RSpec.describe TransactionTypePopulator do
    describe ".call" do
      subject(:call) { described_class.call }

      let(:names) { TransactionType::NAMES }
      let(:credit_names) { names[:credit] }
      let(:debit_names) { names[:debit] }
      let(:total) { credit_names.length + debit_names.length }
      let(:archived_credit_names) { %i[student_loan excluded_benefits] }

      it "creates instances from names" do
        expect { call }.to change(TransactionType, :count).by(total)
      end

      it "assigns the names to the correct operation" do
        call
        expect(TransactionType.debits.count).to eq(debit_names.length)
        expect(TransactionType.credits.count).to eq(credit_names.length - archived_credit_names.length)
        expect(debit_names.map(&:to_s)).to include(TransactionType.debits.first.name)
        expect(credit_names.map(&:to_s)).to include(TransactionType.credits.first.name)
      end

      context "when transaction types exist" do
        before do
          create(:transaction_type, name: "pension", operation: "credit")
          create(:transaction_type, :debit_with_standard_name)
        end

        it "creates one less transaction type" do
          expect { call }.to change(TransactionType, :count).by(total - 2)
        end
      end

      # NOTE: do not use memoized/let `call` - it does not call it twice
      context "when run twice" do
        let(:yesterday) { 1.day.ago }

        it "creates the same total number of instancees" do
          expect {
            described_class.call
            described_class.call
          }.to change(TransactionType, :count).by(total)
        end

        it "does not set archived_at for aleady deactivated student_loan" do
          travel_to(yesterday) do
            described_class.call
            expect(TransactionType.find_by(name: "student_loan").archived_at).to be_within(1.second).of(yesterday)
          end

          described_class.call
          expect(TransactionType.find_by(name: "student_loan").archived_at).to be_within(1.second).of(yesterday)
        end

        it "does not set archived_at for aleady deactivated excluded_benefits" do
          travel_to(yesterday) do
            described_class.call
            expect(TransactionType.find_by(name: "excluded_benefits").archived_at).to be_within(1.second).of(yesterday)
          end

          described_class.call
          expect(TransactionType.find_by(name: "excluded_benefits").archived_at).to be_within(1.second).of(yesterday)
        end
      end

      context "when a transaction type has been removed from the model" do
        before do
          create(:transaction_type, name: :council_tax)
        end

        it "sets the archived_at date" do
          call
          expect(TransactionType.find_by(name: "council_tax").archived_at).not_to be_nil
        end

        it "explicitly sets the archived_at date for student_loan" do
          call
          expect(TransactionType.find_by(name: "student_loan").archived_at).not_to be_nil
        end

        it "explicitly sets the archived_at date for excluded_benefits" do
          call
          expect(TransactionType.find_by(name: "excluded_benefits").archived_at).not_to be_nil
        end

        it "does not set the archived_at date in the database for active transaction types" do
          call
          active_names = names.values.flatten - archived_credit_names
          active_names.each do |transaction_name|
            expect(TransactionType.find_by(name: transaction_name).archived_at).to be_nil
          end
        end
      end
    end

    describe ".call(:without_income)" do
      # this is called from an old migration
      subject(:call) { described_class.call(:without_income) }

      it "does not attempt to update other_income fields" do
        call
        expect(TransactionType.where(other_income: true).count).to eq 0
      end
    end
  end
end
