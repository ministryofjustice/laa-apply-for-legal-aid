require 'rails_helper'

RSpec.describe TransactionType, type: :model do
  describe '#for_income_type?' do
    context 'checks that a boolean response is returned' do
      let!(:credit_transaction) { create :transaction_type, :credit_with_standard_name }

      it ' returns true with a valid income_type' do
        expect(described_class.for_income_type?(credit_transaction['name'])).to eq true
      end
    end

    context 'checks for boolean response' do
      let!(:debit_transaction) { create :transaction_type, :debit_with_standard_name }

      it ' returns false when a non valid income type is used' do
        expect(described_class.for_income_type?(debit_transaction['name'])).to eq false
      end
    end
  end

  describe '#for_outgoing_type?' do
    before { create :transaction_type, :child_care }
    context 'no such outgoing types exist' do
      it 'returns false' do
        expect(TransactionType.for_outgoing_type?('maintenance_out')).to be false
      end
    end

    context 'outgoing types do exist' do
      before { create :transaction_type, :maintenance_out }
      it 'returns true' do
        expect(TransactionType.for_outgoing_type?('maintenance_out')).to be true
      end
    end
  end

  describe '.other_income' do
    it 'returns all other_income type TransactionTypes' do
      Populators::TransactionTypePopulator.call
      names = TransactionType.other_income.pluck(:name)
      expect(names).to eq %w[friends_or_family maintenance_in property_or_lodger student_loan pension]
    end
  end

  context 'hierarchies' do
    before { Populators::TransactionTypePopulator.call }
    let(:benefits) { TransactionType.find_by(name: 'benefits') }
    let(:excluded_benefits) { TransactionType.find_by(name: 'excluded_benefits') }
    let(:pension) { TransactionType.find_by(name: 'pension') }

    describe 'not_children scope' do
      it 'does not return any record that is a child' do
        expect(TransactionType.not_children.pluck(:parent_id).uniq).to eq [nil]
      end
    end

    describe '#child?' do
      context 'is a child' do
        it 'returns true' do
          expect(excluded_benefits.child?).to be true
        end
      end

      context 'is not a child' do
        it 'returns false' do
          expect(benefits.child?).to be false
        end
      end
    end

    describe '#parent?' do
      context 'is a parent' do
        it 'returns true' do
          expect(benefits.parent?).to be true
        end
      end

      context 'is not a parent' do
        it 'returns true' do
          expect(pension.parent?).to be false
        end
      end
    end

    describe '#parent' do
      context 'is not a child' do
        it 'returns nil' do
          expect(pension.parent).to be_nil
        end
      end

      context 'is a child' do
        it 'returns the parent record' do
          expect(excluded_benefits.parent).to eq benefits
        end
      end
    end

    describe 'parent_or_self' do
      context 'is not a child' do
        it 'returns self' do
          expect(pension.parent_or_self).to eq pension
        end
      end

      context 'is a child' do
        it 'returns parent' do
          expect(excluded_benefits.parent_or_self).to eq benefits
        end
      end
    end

    describe '#excluded_benefit?' do
      context 'is excluded benefit type' do
        it 'returns true' do
          expect(excluded_benefits.excluded_benefit?).to eq true
        end
      end
      context 'not an excluded benefit type' do
        it 'returns false' do
          expect(pension.excluded_benefit?).to eq false
        end
      end
    end

    describe '#children' do
      context 'record with no children' do
        it 'returns an empty array' do
          expect(pension.children).to be_empty
        end
      end

      context 'record with children' do
        it 'returns an array of children' do
          expect(benefits.children).to eq [excluded_benefits]
        end
      end
    end

    describe '.find_with_children' do
      context 'one id with no children' do
        it 'return the one record' do
          expect(TransactionType.find_with_children(pension.id)).to eq [pension]
        end
      end

      context 'one id with children' do
        it 'returns the parent and child' do
          expect(TransactionType.find_with_children(benefits.id)).to match_array([benefits, excluded_benefits])
        end
      end

      context 'multiple ids all without children' do
        it 'returns just the records' do
          expect(TransactionType.find_with_children(pension.id, excluded_benefits.id)).to match_array([pension, excluded_benefits])
        end
      end
      context 'multiple ids with and without children' do
        it 'returns the records and the children' do
          expect(TransactionType.find_with_children(pension.id, benefits.id)).to match_array([pension, benefits, excluded_benefits])
        end
      end
    end

    describe '.any_type_of' do
      context 'name of record with children' do
        it 'returns record and its chidlren' do
          expect(TransactionType.any_type_of('benefits')).to match_array([benefits, excluded_benefits])
        end
      end

      context 'name of record with no children' do
        it 'returns just that record in an array' do
          expect(TransactionType.any_type_of('pension')).to eq [pension]
        end
      end

      context 'name that does not exist' do
        it 'returns an empty collection' do
          expect(TransactionType.any_type_of('xxx')).to be_empty
        end
      end
    end

    describe 'active' do
      it 'does not return records with a date in archived at' do
        TransactionType.find_by(name: 'student_loan').update!(archived_at: Time.current)
        expect(TransactionType.active.pluck(:name)).not_to include('student_loan')
      end
    end
  end
end
