require 'rails_helper'

RSpec.describe Dependant, type: :model do
  let(:submission_date) { Time.now }
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, transaction_period_finish_at: submission_date }
  let(:dependant) { create :dependant, legal_aid_application: legal_aid_application, date_of_birth: date_of_birth }

  describe '#ordinal_number' do
    it 'returns the correct ordinal_number' do
      expect(Dependant.new(number: 1).ordinal_number).to eq('first')
      expect(Dependant.new(number: 5).ordinal_number).to eq('fifth')
      expect(Dependant.new(number: 9).ordinal_number).to eq('ninth')
      expect(Dependant.new(number: 10).ordinal_number).to eq('10th')
    end
  end

  describe '#over_fifteen?' do
    context 'Less than 15 years old' do
      let(:date_of_birth) { Time.now - 10.years }

      it 'returns false' do
        expect(dependant.over_fifteen?).to eq(false)
      end
    end

    context 'more than 15 years old' do
      let(:date_of_birth) { Time.now - 20.years }

      it 'returns true' do
        expect(dependant.over_fifteen?).to eq(true)
      end
    end

    context '15 and a half years old' do
      let(:date_of_birth) { Time.now - 15.years + 6.months }

      it 'returns false' do
        expect(dependant.over_fifteen?).to eq(false)
      end
    end

    context '14 and a half years old' do
      let(:date_of_birth) { Time.now - 15.years - 6.months }

      it 'returns false' do
        expect(dependant.over_fifteen?).to eq(false)
      end
    end
  end
end
