require 'rails_helper'

RSpec.describe DependantForm::DetailsForm, type: :form do
  let(:dependant) { create :dependant, date_of_birth: nil }
  let(:date) { Faker::Date.birthday }
  let(:day) { date.strftime('%d') } # Two number day
  let(:month) { date.strftime('%m') } # Two number month
  let(:year) { date.strftime('%Y') } # Four number year
  let(:turn_of_century) { Time.local 2000, 1, 1 }

  let(:params) do
    {
      name: Faker::Lorem.word,
      dob_day: day,
      dob_month: month,
      dob_year: year
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
        let(:date) { Faker::Date.between from: turn_of_century, to: Date.today }

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
end
