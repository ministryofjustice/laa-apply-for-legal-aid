require 'rails_helper'

RSpec.describe Dependant, type: :model do
  let(:calculation_date) { Date.current }
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, transaction_period_finish_on: calculation_date }
  let(:dependant) { create :dependant, legal_aid_application: legal_aid_application, date_of_birth: date_of_birth }

  describe '#ordinal_number' do
    it 'returns the correct ordinal_number' do
      expect(Dependant.new(number: 1).ordinal_number).to eq('first')
      expect(Dependant.new(number: 5).ordinal_number).to eq('fifth')
      expect(Dependant.new(number: 9).ordinal_number).to eq('ninth')
      expect(Dependant.new(number: 10).ordinal_number).to eq('10th')
    end
  end

  context 'population of default values' do
    context 'dependant has nil values' do
      it 'populates them with default values' do
        dependent = create :dependant,
                           in_full_time_education: nil,
                           has_assets_more_than_threshold: nil,
                           has_income: nil,
                           relationship: nil,
                           monthly_income: nil,
                           assets_value: nil
        expect(dependent.in_full_time_education).to be false
        expect(dependent.has_assets_more_than_threshold).to be false
        expect(dependent.has_income).to be false
        expect(dependent.relationship).to eq 'child_relative'
        expect(dependent.monthly_income).to eq 0.0
        expect(dependent.assets_value).to eq 0.0
      end
    end

    context 'dependant has values' do
      it 'does not overwrite the values with defaults' do
        dependent = create :dependant,
                           in_full_time_education: true,
                           has_assets_more_than_threshold: false,
                           has_income: true,
                           relationship: 'adult_relative',
                           monthly_income: 123.45,
                           assets_value: 6789.0
        expect(dependent.in_full_time_education).to be true
        expect(dependent.has_assets_more_than_threshold).to be false
        expect(dependent.has_income).to be true
        expect(dependent.relationship).to eq 'adult_relative'
        expect(dependent.monthly_income).to eq 123.45
        expect(dependent.assets_value).to eq 6789.0
      end
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

  describe '#eighteen_or_less?' do
    context 'Less than 18 years old' do
      let(:date_of_birth) { Time.now - 10.years }

      it 'returns true' do
        expect(dependant.eighteen_or_less?).to eq(true)
      end
    end

    context 'more than 18 years old' do
      let(:date_of_birth) { Time.now - 20.years }

      it 'returns false' do
        expect(dependant.eighteen_or_less?).to eq(false)
      end
    end

    context '18 and a half years old' do
      let(:date_of_birth) { Time.now - 18.years + 6.months }

      it 'returns true' do
        expect(dependant.eighteen_or_less?).to eq(true)
      end
    end

    context '17 and a half years old' do
      let(:date_of_birth) { Time.now - 18.years - 6.months }

      it 'returns true' do
        expect(dependant.eighteen_or_less?).to eq(true)
      end
    end
  end
end
