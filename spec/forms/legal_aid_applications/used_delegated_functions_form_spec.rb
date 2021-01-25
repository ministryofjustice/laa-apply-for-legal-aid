require 'rails_helper'

RSpec.describe LegalAidApplications::UsedDelegatedFunctionsForm, type: :form, vcr: { cassette_name: 'gov_uk_bank_holiday_api' } do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:used_delegated_functions) { true }
  let(:used_delegated_functions_reported_on) { Date.today }
  let(:used_delegated_functions_on) { rand(20).days.ago.to_date }
  let(:day) { used_delegated_functions_on.day }
  let(:month) { used_delegated_functions_on.month }
  let(:year) { used_delegated_functions_on.year }
  let(:i18n_scope) { 'activemodel.errors.models.legal_aid_application.attributes' }
  let(:error_locale) { :defined_in_spec }
  let(:message) { I18n.t(error_locale, scope: i18n_scope) }

  let(:params) do
    {
      used_delegated_functions_on_3i: day.to_s,
      used_delegated_functions_on_2i: month.to_s,
      used_delegated_functions_on_1i: year.to_s,
      used_delegated_functions: used_delegated_functions.to_s
    }
  end

  subject { described_class.new(params.merge(model: legal_aid_application)) }

  describe '#save' do
    before do
      subject.save
      legal_aid_application.reload
    end

    it 'updates the application' do
      expect(legal_aid_application.used_delegated_functions_reported_on).to eq(used_delegated_functions_reported_on)
      expect(legal_aid_application.used_delegated_functions_on).to eq(used_delegated_functions_on)
      expect(legal_aid_application.used_delegated_functions).to be used_delegated_functions
    end

    it 'updates the substantive application deadline' do
      deadline = SubstantiveApplicationDeadlineCalculator.call(legal_aid_application.reload)
      expect(legal_aid_application.substantive_application_deadline_on).to eq(deadline)
    end

    context 'date is exactly 12 months ago' do
      let(:used_delegated_functions_on) { 12.months.ago }

      it 'is valid' do
        expect(subject).to be_valid
      end

      it 'updates the application' do
        expect(legal_aid_application.used_delegated_functions_on).to eq(used_delegated_functions_on.to_date)
      end
    end

    context 'when not using delegated functions selected' do
      let(:used_delegated_functions) { false }

      it 'updates the application' do
        expect(legal_aid_application.used_delegated_functions).to be used_delegated_functions
      end

      it 'does not update the date' do
        expect(legal_aid_application.used_delegated_functions_on).to be_nil
      end

      it 'does not update the reported on date' do
        expect(legal_aid_application.used_delegated_functions_reported_on).to be_nil
      end

      it 'does not update the substantive application deadline' do
        expect(legal_aid_application.substantive_application_deadline_on).to be_nil
      end
    end

    context 'when not using delegated functions selected and date exists on model' do
      let(:used_delegated_functions) { false }
      let(:legal_aid_application) { create :legal_aid_application, used_delegated_functions_on: 1.day.ago, used_delegated_functions_reported_on: 1.day.ago }

      it 'updates the application' do
        expect(legal_aid_application.used_delegated_functions).to be used_delegated_functions
      end

      it 'deletes the date' do
        expect(legal_aid_application.used_delegated_functions_on).to be_nil
      end

      it 'deletes the reported on date' do
        expect(legal_aid_application.used_delegated_functions_reported_on).to be_nil
      end

      it 'deletes the substantive application deadline' do
        expect(legal_aid_application.substantive_application_deadline_on).to be_nil
      end
    end

    context 'when nothing selected' do
      let(:params) { {} }
      let(:error_locale) { 'used_delegated_functions.blank' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors[:used_delegated_functions].join).to match(message)
      end
    end

    context 'when date is invalid' do
      let(:month) { 15 }
      let(:error_locale) { 'used_delegated_functions_on.date_not_valid' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors[:used_delegated_functions_on].join).to match(message)
      end
    end

    context 'date is older than 12 months ago' do
      let(:used_delegated_functions_on) { 13.months.ago }
      let(:error_locale) { 'used_delegated_functions_on.date_not_in_range' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors[:used_delegated_functions].join).to match(I18n.t(error_locale, scope: i18n_scope, months: Time.zone.now.ago(12.months).strftime('%d %m %Y')))
      end
    end

    context 'when occurred on is in future' do
      let(:used_delegated_functions_on) { 1.days.from_now.to_date }
      let(:error_locale) { 'used_delegated_functions_on.date_is_in_the_future' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors[:used_delegated_functions_on].join).to match(message)
      end
    end

    context 'with delegated function selected but without date' do
      let(:params) { { used_delegated_functions: 'true' } }
      let(:legal_aid_application) { create :legal_aid_application, used_delegated_functions_on: nil }
      let(:error_locale) { 'used_delegated_functions_on.blank' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors[:used_delegated_functions_on].join).to match(message)
      end
    end

    context 'with a partial date' do
      let(:error_locale) { 'used_delegated_functions_on.date_not_valid' }
      let(:params) do
        {
          used_delegated_functions_on_1i: year.to_s,
          used_delegated_functions_on_2i: '',
          used_delegated_functions_on_3i: day.to_s,
          used_delegated_functions: used_delegated_functions.to_s
        }
      end

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors[:used_delegated_functions_on].join).to match(message)
      end
    end

    describe '#save_as_draft' do
      before do
        subject.save_as_draft
        legal_aid_application.reload
      end

      it 'updates the legal_aid_application' do
        expect(legal_aid_application.used_delegated_functions_on).to eq(used_delegated_functions_on)
      end

      context 'when occurred on is invalid' do
        let(:month) { 15 }
        let(:error_locale) { 'used_delegated_functions_on.date_not_valid' }

        it 'is invalid' do
          expect(subject).to be_invalid
        end

        it 'generates the expected error message' do
          expect(message).not_to match(/^translation missing:/)
          expect(subject.errors[:used_delegated_functions_on].join).to match(message)
        end
      end

      context 'when occurred on is in future' do
        let(:used_delegated_functions_on) { 1.days.from_now.to_date }
        let(:error_locale) { 'used_delegated_functions_on.date_is_in_the_future' }

        it 'is invalid' do
          expect(subject).to be_invalid
        end

        it 'generates the expected error message' do
          expect(message).not_to match(/^translation missing:/)
          expect(subject.errors[:used_delegated_functions_on].join).to match(message)
        end
      end

      context 'without date' do
        let(:params) { {} }
        let(:legal_aid_application) { create :legal_aid_application, used_delegated_functions_on: nil }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end
end
