require "rails_helper"

RSpec.shared_context "with credit and debit transaction types" do
  let(:credit_transaction_type) { create(:transaction_type, :benefits) }
  let(:debit_transaction_type) { create(:transaction_type, :rent_or_mortgage) }

  before do
    credit_transaction_type
    debit_transaction_type
  end
end

RSpec.describe TransactionType, type: :model do
  describe ".all" do
    subject(:all) { described_class.all }

    include_context "with credit and debit transaction types"

    it "returns all" do
      expect(all).to contain_exactly(credit_transaction_type, debit_transaction_type)
    end
  end

  describe ".credits" do
    subject(:credits) { described_class.credits }

    include_context "with credit and debit transaction types"

    it "returns just the credit types" do
      expect(credits).to contain_exactly(credit_transaction_type)
    end
  end

  describe ".debits" do
    subject(:debits) { described_class.debits }

    include_context "with credit and debit transaction types"

    it "returns just the debit types" do
      expect(debits).to contain_exactly(debit_transaction_type)
    end
  end

  describe ".for_income_type?" do
    context "when checks that a boolean response is returned" do
      let!(:credit_transaction) { create(:transaction_type, :credit_with_standard_name) }

      it "returns true with a valid income_type" do
        expect(described_class.for_income_type?(credit_transaction["name"])).to be true
      end
    end

    context "with checks for boolean response" do
      let!(:debit_transaction) { create(:transaction_type, :debit_with_standard_name) }

      it "returns false when a non valid income type is used" do
        expect(described_class.for_income_type?(debit_transaction["name"])).to be false
      end
    end
  end

  describe ".for_outgoing_type?" do
    before { create(:transaction_type, :child_care) }

    context "when no such outgoing types exist" do
      it "returns false" do
        expect(described_class.for_outgoing_type?("maintenance_out")).to be false
      end
    end

    context "when outgoing types do exist" do
      before { create(:transaction_type, :maintenance_out) }

      it "returns true" do
        expect(described_class.for_outgoing_type?("maintenance_out")).to be true
      end
    end
  end

  describe ".other_income" do
    it "returns all other_income type TransactionTypes" do
      Populators::TransactionTypePopulator.call
      names = described_class.other_income.pluck(:name)
      expect(names).to eq %w[friends_or_family maintenance_in property_or_lodger student_loan pension]
    end
  end

  context "with hierarchies" do
    before { Populators::TransactionTypePopulator.call }

    let(:benefits) { described_class.find_by(name: "benefits") }
    let(:excluded_benefits) { described_class.find_by(name: "excluded_benefits") }
    let(:housing_benefit) { described_class.find_by(name: "housing_benefit") }
    let(:pension) { described_class.find_by(name: "pension") }

    describe "not_children scope" do
      it "does not return any record that is a child" do
        expect(described_class.not_children.pluck(:parent_id).uniq).to eq [nil]
      end
    end

    describe "#child?" do
      context "when is a child" do
        it "returns true" do
          expect(excluded_benefits.child?).to be true
        end
      end

      context "when is not a child" do
        it "returns false" do
          expect(benefits.child?).to be false
        end
      end
    end

    describe "parent_or_self" do
      context "when is not a child" do
        it "returns self" do
          expect(pension.parent_or_self).to eq pension
        end
      end

      context "when is a child" do
        it "returns parent" do
          expect(excluded_benefits.parent_or_self).to eq benefits
        end
      end
    end

    describe "#disregarded_benefit?" do
      context "when a disregarded benefit type" do
        it "returns true" do
          expect(excluded_benefits.disregarded_benefit?).to be true
        end
      end

      context "when not a disregarded benefit type" do
        it "returns false" do
          expect(pension.disregarded_benefit?).to be false
        end
      end
    end

    describe "#children" do
      context "with record with no children" do
        it "returns an empty array" do
          expect(pension.children).to be_empty
        end
      end

      context "with record with children" do
        it "returns an array of children" do
          expect(benefits.children).to contain_exactly(excluded_benefits, housing_benefit)
        end
      end
    end

    describe "active" do
      it "does not return records with a date in archived at" do
        described_class.find_by(name: "student_loan").update!(archived_at: Time.current)
        expect(described_class.active.pluck(:name)).not_to include("student_loan")
      end
    end
  end
end
