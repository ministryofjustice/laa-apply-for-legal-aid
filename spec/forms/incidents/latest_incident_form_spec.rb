require 'rails_helper'

RSpec.describe Incidents::LatestIncidentForm, type: :form do
  let(:incident) { create :incident }
  let(:occurred_on) { rand(20).days.ago.to_date }
  let(:details) { Faker::Lorem.paragraph }
  let(:i18n_scope) { 'activemodel.errors.models.incident.attributes' }
  let(:error_locale) { :foo }
  let(:message) { I18n.t(error_locale, scope: i18n_scope) }

  let(:params) { { occurred_on: occurred_on, details: details } }

  subject { described_class.new(params.merge(model: incident)) }

  describe '#save' do
    before do
      subject.save
      incident.reload
    end

    it 'updates the incident' do
      expect(incident.details).to eq(details)
      expect(incident.occurred_on).to eq(occurred_on)
    end

    context 'when occurred on is invalid' do
      let(:params) do
        {
          details: details,
          occurred_year: occurred_on.year.to_s,
          occurred_month: '55',
          occurred_day: occurred_on.day.to_s
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

    context 'when occurred on is in future' do
      let(:occurred_on) { 1.days.from_now.to_date }
      let(:error_locale) { 'occurred_on.date_is_in_the_future' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates an error' do
        expect(subject.errors[:occurred_on].join).to match(message)
      end
    end

    context 'with date entered in parts' do
      let(:params) do
        {
          details: details,
          occurred_year: occurred_on.year.to_s,
          occurred_month: occurred_on.month.to_s,
          occurred_day: occurred_on.day.to_s
        }
      end

      it 'updates the incident' do
        expect(incident.details).to eq(details)
        expect(incident.occurred_on).to eq(occurred_on)
      end
    end

    context 'without date' do
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

    context 'with an invalid partial date' do
      let(:error_locale) { 'occurred_on.date_not_valid' }
      let(:params) do
        {
          details: details,
          occurred_year: occurred_on.year.to_s,
          occurred_month: '',
          occurred_day: occurred_on.day.to_s
        }
      end

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates an error' do
        expect(subject.errors[:occurred_on].join).to match(message)
      end
    end

    context 'without detail' do
      let(:details) { '' }
      let(:incident) { create :incident, details: nil }
      let(:error_locale) { 'details.blank' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates an error' do
        expect(subject.errors[:details].join).to match(message)
      end
    end
  end

  describe '#save_as_draft' do
    before do
      subject.save_as_draft
      incident.reload
    end

    it 'updates the incident' do
      expect(incident.details).to eq(details)
      expect(incident.occurred_on).to eq(occurred_on)
    end

    context 'when occurred on is invalid' do
      let(:occurred_on) { '55-55-1955' }
      let(:error_locale) { 'occurred_on.date_not_valid' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates an error' do
        expect(subject.errors[:occurred_on].join).to match(message)
      end
    end

    context 'when occurred on is in future' do
      let(:occurred_on) { 1.days.from_now.to_date }
      let(:error_locale) { 'occurred_on.date_is_in_the_future' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates an error' do
        expect(subject.errors[:occurred_on].join).to match(message)
      end
    end

    context 'with date entered in parts' do
      let(:params) do
        {
          details: details,
          occurred_year: occurred_on.year.to_s,
          occurred_month: occurred_on.month.to_s,
          occurred_day: occurred_on.day.to_s
        }
      end

      it 'updates the incident' do
        expect(incident.details).to eq(details)
        expect(incident.occurred_on).to eq(occurred_on)
      end
    end

    context 'without date' do
      let(:occurred_on) { '' }
      let(:incident) { create :incident, occurred_on: nil }

      it 'is valid' do
        expect(subject).to be_valid
      end

      it 'save details' do
        expect(incident.details).to eq(details)
      end
    end

    context 'without detail' do
      let(:params) do
        {
          details: '',
          occurred_year: occurred_on.year.to_s,
          occurred_month: occurred_on.month.to_s,
          occurred_day: occurred_on.day.to_s
        }
      end
      let(:incident) { create :incident, details: nil }

      it 'is valid' do
        expect(subject).to be_valid
      end

      it 'updates occurred on' do
        # Note, fails if date passed in as `occurred_on` rather than in day, month, year format.
        expect(incident.occurred_on).to eq(occurred_on)
      end
    end
  end
end
