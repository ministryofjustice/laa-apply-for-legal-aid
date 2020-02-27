require 'rails_helper'

RSpec.describe SavingsAmount, type: :model do
  describe '#positive' do
    subject { create :savings_amount }

    context 'has no savings' do
      it 'is negative' do
        expect(subject.positive?).to eq(false)
      end
    end

    context 'has some savings' do
      before { subject.update!(cash: rand(1...1_000_000.0).round(2)) }

      it 'is positive' do
        expect(subject.positive?).to eq(true)
      end
    end
  end

  describe '#values?' do
    subject { create :savings_amount, :with_values }

    context 'has savings and investments' do
      it 'returns true' do
        expect(subject.values?).to eq true
      end
    end

    context 'when it has a single value, set to 0' do
      subject { create :savings_amount, offline_current_accounts: 0_0 }

      it 'returns true' do
        expect(subject.values?).to be true
      end
    end

    context 'has no savings and investments' do
      subject { create :savings_amount, :all_nil }
      it 'returns false' do
        expect(subject.values?).to eq false
      end
    end
  end
end
