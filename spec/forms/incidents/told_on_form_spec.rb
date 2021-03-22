require 'rails_helper'

RSpec.describe Incidents::ToldOnForm, type: :form do
  let(:incident) { create :incident }
  let(:told_on) { 3.days.ago.to_date }
  let(:occurred_on) { 5.days.ago.to_date }
  let(:i18n_scope) { 'activemodel.errors.models.application_merits_task/incident.attributes' }
  let(:error_locale) { :defined_in_spec }
  let(:message) { I18n.t(error_locale, scope: i18n_scope) }

  let(:params) { { occurred_on: occurred_on, told_on: told_on } }

  subject { described_class.new(params.merge(model: incident)) }

  describe '#save' do
    before do
      subject.save
      incident.reload
    end

    it 'updates the incident' do
      expect(incident.occurred_on).to eq(occurred_on)
      expect(incident.told_on).to eq(told_on)
    end

    context 'when occurred on is invalid' do
      let(:params) do
        {
          occurred_on_1i: occurred_on.year.to_s,
          occurred_on_2i: '55',
          occurred_on_3i: occurred_on.day.to_s
        }
      end
      let(:error_locale) { 'occurred_on.date_not_valid' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates an error' do
        expect(subject.errors[:occurred_on].join).to match(message)
      end
    end

    context 'when told on is invalid' do
      let(:params) do
        {
          told_on_1i: told_on.year.to_s,
          told_on_2i: '55',
          told_on_3i: told_on.day.to_s
        }
      end
      let(:error_locale) { 'told_on.date_not_valid' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates an error' do
        expect(subject.errors[:told_on].join).to match(message)
      end
    end

    context 'when occurred on is in future' do
      let(:occurred_on) { 1.day.from_now.to_date }
      let(:error_locale) { 'occurred_on.date_is_in_the_future' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates an error' do
        expect(subject.errors[:occurred_on].join).to match(message)
      end
    end

    context 'when told on is in future' do
      let(:told_on) { 1.day.from_now.to_date }
      let(:error_locale) { 'told_on.date_is_in_the_future' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates an error' do
        expect(subject.errors[:told_on].join).to match(message)
      end
    end

    context 'with told date entered in parts' do
      let(:params) do
        {
          told_on_1i: told_on.year.to_s,
          told_on_2i: told_on.month.to_s,
          told_on_3i: told_on.day.to_s
        }
      end

      it 'updates the incident' do
        expect(incident.told_on).to eq(told_on)
      end
    end

    context 'without occurred on date' do
      let(:occurred_on) { '' }
      let(:incident) { create :incident, occurred_on: nil }
      let(:error_locale) { 'occurred_on.blank' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates an error' do
        expect(subject.errors[:occurred_on].join).to match(message)
      end
    end

    context 'without told on date' do
      let(:told_on) { '' }
      let(:incident) { create :incident, told_on: nil }
      let(:error_locale) { 'told_on.blank' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates an error' do
        expect(subject.errors[:told_on].join).to match(message)
      end
    end

    context 'with an invalid partial occurred on date' do
      let(:error_locale) { 'occurred_on.date_not_valid' }
      let(:params) do
        {
          occurred_on_1i: occurred_on.year.to_s,
          occurred_on_2i: '',
          occurred_on_3i: occurred_on.day.to_s
        }
      end

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates an error' do
        expect(subject.errors[:occurred_on].join).to match(message)
      end
    end

    context 'with an invalid partial told on date' do
      let(:error_locale) { 'told_on.date_not_valid' }
      let(:params) do
        {
          told_on_1i: told_on.year.to_s,
          told_on_2i: '',
          told_on_3i: told_on.day.to_s
        }
      end

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates an error' do
        expect(subject.errors[:told_on].join).to match(message)
      end
    end
  end
end
