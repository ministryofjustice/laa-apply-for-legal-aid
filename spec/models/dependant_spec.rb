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

  describe '#as_json' do
    context 'dependant has nil values' do
      let(:dependant) do
        create :dependant,
               date_of_birth: Date.new(2019, 3, 2),
               in_full_time_education: nil,
               has_assets_more_than_threshold: nil,
               has_income: nil,
               relationship: nil,
               monthly_income: nil,
               assets_value: nil
      end
      let(:expected_hash) do
        {
          date_of_birth: '2019-03-02',
          in_full_time_education: false,
          relationship: 'child_relative',
          monthly_income: 0.0,
          assets_value: 0.0
        }
      end
      it 'returns the expected hash' do
        expect(dependant.as_json).to eq expected_hash
      end
    end

    context 'dependant has values' do
      let(:dependant) do
        create :dependant,
               date_of_birth: Date.new(2019, 3, 2),
               in_full_time_education: true,
               has_assets_more_than_threshold: false,
               has_income: true,
               relationship: 'adult_relative',
               monthly_income: 123.45,
               assets_value: 6789.0
      end
      let(:expected_hash) do
        {
          date_of_birth: '2019-03-02',
          in_full_time_education: true,
          relationship: 'adult_relative',
          monthly_income: 123.45,
          assets_value: 6789.0
        }
      end
      it 'returns the expected hash' do
        expect(dependant.as_json).to eq expected_hash
      end
    end
  end

  describe '#over_fifteen?' do
    context 'Less than 15 years old' do
      let(:date_of_birth) { Time.current - 10.years }

      it 'returns false' do
        expect(dependant.over_fifteen?).to eq(false)
      end
    end

    context 'more than 15 years old' do
      let(:date_of_birth) { Time.current - 20.years }

      it 'returns true' do
        expect(dependant.over_fifteen?).to eq(true)
      end
    end

    context '15 and a half years old' do
      let(:date_of_birth) { Time.current - 15.years + 6.months }

      it 'returns false' do
        expect(dependant.over_fifteen?).to eq(false)
      end
    end

    context '14 and a half years old' do
      let(:date_of_birth) { Time.current - 15.years - 6.months }

      it 'returns false' do
        expect(dependant.over_fifteen?).to eq(false)
      end
    end
  end

  describe '#eighteen_or_less?' do
    context 'Less than 18 years old' do
      let(:date_of_birth) { Time.current - 10.years }

      it 'returns true' do
        expect(dependant.eighteen_or_less?).to eq(true)
      end
    end

    context 'more than 18 years old' do
      let(:date_of_birth) { Time.current - 20.years }

      it 'returns false' do
        expect(dependant.eighteen_or_less?).to eq(false)
      end
    end

    context '18 and a half years old' do
      let(:date_of_birth) { Time.current - 18.years + 6.months }

      it 'returns true' do
        expect(dependant.eighteen_or_less?).to eq(true)
      end
    end

    context '17 and a half years old' do
      let(:date_of_birth) { Time.current - 18.years - 6.months }

      it 'returns true' do
        expect(dependant.eighteen_or_less?).to eq(true)
      end
    end
  end
end
