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
  describe '#sum_amounts?' do
    subject { create :savings_amount, :with_values }
    context 'has savings and investments' do
      it 'is not zero' do
        expect(subject.sum_amounts?).not_to eq(0)
      end
    end
    context 'has no savings and investments' do
      subject { create :savings_amount, :all_nil }
      it 'is zero' do
        expect(subject.sum_amounts?).to eq(0)
      end
    end
  end
end
