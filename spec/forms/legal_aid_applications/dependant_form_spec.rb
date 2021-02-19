require 'rails_helper'

RSpec.describe LegalAidApplications::DependantForm do
  let(:dependant) { create :dependant, date_of_birth: nil }
  let(:date) { Faker::Date.birthday }
  let(:day) { date.strftime('%d') } # Two number day
  let(:month) { date.strftime('%m') } # Two number month
  let(:year) { date.strftime('%Y') } # Four number year
  let(:turn_of_century) { Time.zone.local 2000, 1, 1 }
  let(:has_assets) { 'false' }
  let(:assets_value) { '' }
  let(:has_income) { 'false' }
  let(:monthly_income) { '' }

  let(:params) do
    {
      name: Faker::Lorem.word,
      date_of_birth_3i: day,
      date_of_birth_2i: month,
      date_of_birth_1i: year,
      relationship: 'child_relationship',
      monthly_income: monthly_income,
      has_income: has_income,
      in_full_time_education: 'false',
      has_assets_more_than_threshold: has_assets,
      assets_value: assets_value
    }
  end

  subject { described_class.new(params) }

  describe 'valid?' do
    it 'returns true when validations pass' do
      expect(subject).to be_valid
    end

    context 'when invalid' do
      let(:year) { 2.years.from_now.year }

      it 'returns false when validations fail' do
        expect(subject).not_to be_valid
      end
    end
  end

  describe 'date_of_birth' do
    it 'matches the input' do
      expect(subject.date_of_birth).to eq(date)
    end

    context 'with two character year' do
      let(:year) { date.strftime('%y') }

      context 'in 20th century' do
        let(:date) { Faker::Date.between from: 99.years.ago, to: turn_of_century }

        it 'constructs correct date' do
          expect(subject.date_of_birth).to eq(date)
        end
      end

      context 'in 21st century' do
        let(:date) { Faker::Date.between from: turn_of_century, to: Time.zone.today }

        it 'constructs correct date' do
          expect(subject.date_of_birth).to eq(date)
        end
      end
    end

    shared_examples 'invalid date' do
      let(:invalid_date_message) { I18n.t('activemodel.errors.models.dependant.attributes.date_of_birth.date_not_valid') }

      it 'invalidates form' do
        expect(subject).to be_invalid
      end

      it 'has invalid date of birth error message' do
        subject.valid?
        expect(subject.errors[:date_of_birth]).to include(invalid_date_message)
      end
    end

    context 'with three digit year' do
      let(:year) { date.year.to_s[1, 3] }

      it_behaves_like 'invalid date'
    end

    context 'with one digit year' do
      let(:year) { (0..9).to_a.sample }

      it_behaves_like 'invalid date'
    end

    context 'with three digit month' do
      let(:month) { Faker::Number.number(digits: 3) }

      it_behaves_like 'invalid date'
    end

    context 'with three digit day' do
      let(:day) { Faker::Number.number(digits: 3) }

      it_behaves_like 'invalid date'
    end
  end

  describe 'assets' do
    before { subject.valid? }

    context 'when the dependant has assets' do
      let(:has_assets) { 'true' }

      context 'with no value specified' do
        let(:expected_array) do
          [
            I18n.t('activemodel.errors.models.dependant.attributes.assets_value.blank'),
            I18n.t('activemodel.errors.models.dependant.attributes.assets_value.not_a_number')
          ]
        end

        it 'raises the expected error' do
          expect(subject.errors[:assets_value]).to eq expected_array
        end
      end

      context 'with a value below the threshold' do
        let(:assets_value) { '5000' }
        let(:expected_array) { [I18n.t('activemodel.errors.models.dependant.attributes.assets_value.less_than_threshold')] }

        it 'raises the expected error' do
          expect(subject.errors[:assets_value]).to eq expected_array
        end
      end

      context 'with a value above the threshold' do
        let(:assets_value) { '9,000' }

        it 'raises the expected error' do
          expect(subject.valid?).to be true
        end
      end
    end

    context 'when the assets question is blank' do
      let(:has_assets) { '' }
      let(:assets_value) { '' }
      let(:expected_array) do
        [
          I18n.t('activemodel.errors.models.dependant.attributes.has_assets_more_than_threshold.blank_message')
        ]
      end

      it 'raises the expected error' do
        expect(subject.errors[:has_assets_more_than_threshold]).to eq expected_array
      end
    end
  end

  describe 'income' do
    before { subject.valid? }

    context 'when the dependant has income' do
      let(:has_income) { 'true' }

      context 'with no value specified' do
        let(:expected_array) { [I18n.t('activemodel.errors.models.dependant.attributes.monthly_income.blank')] }

        it 'raises the expected error' do
          expect(subject.errors[:monthly_income]).to eq expected_array
        end
      end

      context 'with a value specified' do
        let(:monthly_income) { '1,000.00' }

        it { expect(subject.valid?).to be true }
      end
    end

    context 'when the income question is blank' do
      let(:has_income) { '' }
      let(:expected_array) { [I18n.t('activemodel.errors.models.dependant.attributes.has_income.blank_message')] }

      it 'raises the expected error' do
        expect(subject.errors[:has_income]).to eq expected_array
      end
    end
  end
end
