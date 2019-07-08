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
end
