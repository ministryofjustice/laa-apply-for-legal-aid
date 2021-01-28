require 'rails_helper'

RSpec.describe DateFieldBuilder do
  let(:form_date) { Time.zone.today }
  let(:model_date) { 2.days.ago }
  let(:model) { OpenStruct.new(happened_on: model_date) }
  let(:form) do
    OpenStruct.new(
      happened_day: form_date.day,
      happened_month: form_date.month,
      happened_year: form_date.year
    )
  end
  let(:suffix) { nil }

  subject do
    described_class.new(
      form: form,
      model: model,
      method: :happened_on,
      prefix: :happened_,
      suffix: suffix
    )
  end

  describe '#fields' do
    it 'returns three prefixed names for day, month, and year' do
      expect(subject.fields).to eq(%i[happened_year happened_month happened_day])
    end
  end

  describe '#from_form' do
    it 'returns array of data stored in form prefixed part fields' do
      expect(subject.from_form).to eq([form_date.year, form_date.month, form_date.day])
    end
  end

  describe '#model_attributes' do
    it 'returns hash of data for form build from model date' do
      expected = {
        happened_day: model_date.day,
        happened_month: model_date.month,
        happened_year: model_date.year
      }
      expect(subject.model_attributes).to eq(expected)
    end
  end

  describe '#model_date' do
    it 'returns date from model' do
      expect(subject.model_date).to eq(model_date)
    end
  end

  describe '#form_date' do
    it 'returns date built from form part fields' do
      expect(subject.form_date).to eq(form_date)
    end

    context 'with two character year' do
      let(:form) do
        OpenStruct.new(
          happened_day: form_date.day,
          happened_month: form_date.month,
          happened_year: form_date.strftime('%y')
        )
      end

      it 'returns date built from form part fields' do
        expect(subject.form_date).to eq(form_date)
      end
    end
  end

  describe '#form_date_invalid?' do
    it 'returns false with valid date data' do
      expect(subject.form_date_invalid?).to be false
    end

    context 'with invalid data' do
      let(:form) do
        OpenStruct.new(
          happened_day: form_date.day,
          happened_month: 15,
          happened_year: form_date.year
        )
      end

      it 'returns false' do
        expect(subject.form_date_invalid?).to be true
      end
    end

    context 'with two character year' do
      let(:form) do
        OpenStruct.new(
          happened_day: form_date.day,
          happened_month: form_date.month,
          happened_year: form_date.strftime('%y')
        )
      end

      it 'returns false with valid date data' do
        expect(subject.form_date_invalid?).to be false
      end
    end

    context 'with one character year' do
      let(:form) do
        OpenStruct.new(
          happened_day: form_date.day,
          happened_month: form_date.month,
          happened_year: form_date.strftime('%y').last
        )
      end

      it 'returns true' do
        expect(subject.form_date_invalid?).to be true
      end
    end
  end

  describe '#blank?' do
    it 'returns false if fully populated' do
      expect(subject.blank?).to be false
    end

    context 'when all form part fields are empty' do
      let(:form) { OpenStruct.new }

      it 'returns true' do
        expect(subject.blank?).to be true
      end
    end
  end

  describe '#partially_complete?' do
    it 'returns false if fully populated' do
      expect(subject.partially_complete?).to be false
    end

    context 'when one part field is empty' do
      let(:form) do
        OpenStruct.new(
          happened_day: form_date.day,
          happened_year: form_date.year
        )
      end

      it 'returns true' do
        expect(subject.partially_complete?).to be true
      end
    end

    context 'when all part fields empty' do
      let(:form) do
        OpenStruct.new
      end

      it 'returns false' do
        expect(subject.partially_complete?).to be false
      end
    end
  end

  context 'when a suffix is set' do
    let(:suffix) { :gov_uk }

    let(:form) do
      OpenStruct.new(
        happened_3i: form_date.day,
        happened_2i: form_date.month,
        happened_1i: form_date.strftime('%y')
      )
    end

    it 'returns date built from form new style part fields' do
      expect(subject.form_date).to eq(form_date)
    end
  end
end
