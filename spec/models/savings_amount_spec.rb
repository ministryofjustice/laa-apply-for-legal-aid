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
      before { subject.update!(cash: Faker::Number.decimal.to_d) }

      it 'is positive' do
        expect(subject.positive?).to eq(true)
      end
    end
  end
end
