require 'rails_helper'

RSpec.describe LegalAidApplications::DelegatedFunctionsDateForm, type: :form, vcr: { cassette_name: 'gov_uk_bank_holiday_api' } do
  let(:legal_aid_application) { create :legal_aid_application, used_delegated_functions_on: '12/12/2020' }
  let(:confirm_delegated_functions_date) { true }
  let(:used_delegated_functions_reported_on) { Time.zone.today }
  let(:used_delegated_functions_on) { rand(20).days.ago.to_date }
  let(:day) { used_delegated_functions_on.day }
  let(:month) { used_delegated_functions_on.month }
  let(:year) { used_delegated_functions_on.year }
  let(:i18n_scope) { 'activemodel.errors.models.legal_aid_application.attributes' }
  let(:error_locale) { :defined_in_spec }
  let(:message) { I18n.t(error_locale, scope: i18n_scope) }

  let(:params) do
    {
      used_delegated_functions_day: day.to_s,
      used_delegated_functions_month: month.to_s,
      used_delegated_functions_year: year.to_s,
      confirm_delegated_functions_date: confirm_delegated_functions_date.to_s
    }
  end

  subject { described_class.new(params.merge(model: legal_aid_application)) }

  describe '#save' do
    before do
      subject.save
      legal_aid_application.reload
    end

    it 'does not update the application' do
      expect(legal_aid_application.used_delegated_functions_on).to eq(Date.parse('12/12/2020'))
    end

    context 'confirm_delegated_functions_date is false' do
      let(:confirm_delegated_functions_date) { false }

      context 'edited used delegated functions date' do
        it 'updates the application' do
          expect(legal_aid_application.used_delegated_functions_reported_on).to eq(used_delegated_functions_reported_on)
          expect(legal_aid_application.used_delegated_functions_on).to eq(used_delegated_functions_on)
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
          expect(subject.errors[:confirm_delegated_functions_date].join).to match(I18n.t(error_locale, scope: i18n_scope,
                                                                                                       months: Time.zone.now.ago(12.months).strftime('%d %m %Y')))
        end
      end

      context 'when occurred on is in future' do
        let(:used_delegated_functions_on) { 1.day.from_now.to_date }
        let(:error_locale) { 'used_delegated_functions_on.date_is_in_the_future' }

        it 'is invalid' do
          expect(subject).to be_invalid
        end

        it 'generates the expected error message' do
          expect(message).not_to match(/^translation missing:/)
          expect(subject.errors[:used_delegated_functions_on].join).to match(message)
        end
      end

      context 'changed the delegated functions date' do
        let(:legal_aid_application) { create :legal_aid_application, used_delegated_functions_on: rand(20).days.ago.to_date }
        context 'edited date is blank' do
          let(:day) { nil }
          let(:month) { nil }
          let(:year) { nil }
          let(:error_locale) { 'used_delegated_functions_on.blank' }

          it 'is invalid' do
            expect(subject).to be_invalid
          end

          it 'generates the expected error message' do
            expect(message).not_to match(/^translation missing:/)
            expect(subject.errors[:used_delegated_functions_on].join).to match(message)
          end
        end
      end

      context 'with a partial date' do
        let(:error_locale) { 'used_delegated_functions_on.date_not_valid' }
        let(:params) do
          {
            used_delegated_functions_year: year.to_s,
            used_delegated_functions_month: '',
            used_delegated_functions_day: day.to_s,
            confirm_delegated_functions_date: confirm_delegated_functions_date
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
    end

    context 'confirm_delegated_functions_date is nil' do
      let(:confirm_delegated_functions_date) { nil }

      it 'generates the expected error message' do
        expect(subject.errors[:confirm_delegated_functions_date].join).to match(I18n.t('.confirm_delegated_functions_date.blank', scope: i18n_scope))
      end
    end

    describe '#save_as_draft' do
      let(:confirm_delegated_functions_date) { false }

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
        let(:used_delegated_functions_on) { 1.day.from_now.to_date }
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

      context 'confirmed the delegated functions date' do
        let(:confirm_delegated_functions_date) { true }

        before do
          subject.save_as_draft
          legal_aid_application.reload
        end

        it 'does not update the application' do
          expect(legal_aid_application.used_delegated_functions_on).to eq(Date.parse('12/12/2020'))
        end
      end
    end
  end
end
