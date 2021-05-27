require 'rails_helper'

RSpec.describe LegalAidApplications::ConfirmDelegatedFunctionsDateForm, type: :form, vcr: { cassette_name: 'gov_uk_bank_holiday_api' } do
  let!(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_delegated_functions }
  let(:application_proceeding_types) { legal_aid_application.application_proceeding_types }
  let(:application_proceedings_by_name) { legal_aid_application.application_proceedings_by_name }
  let(:today) { Time.zone.today }
  let(:used_delegated_functions_reported_on) { today }
  let(:used_delegated_functions_on) { rand(19).days.ago.to_date }
  let(:default_params) { { confirm_delegated_functions_date: 'false' } }
  let(:i18n_scope) { 'activemodel.errors.models.application_proceeding_types.attributes' }
  let(:error_locale) { :defined_in_spec }
  let(:meaning) { legal_aid_application.proceeding_types.first.meaning }

  let(:params) { update_proceeding_type_param_dates }

  subject { described_class.call(application_proceedings_by_name) }

  describe '#save' do
    before do
      subject.save(params)
      application_proceeding_types.reload
    end

    it 'updates each application proceeding type' do
      application_proceeding_types.each_with_index do |type, i|
        expect(type.used_delegated_functions_reported_on).to eq(used_delegated_functions_reported_on)
        expect(type.used_delegated_functions_on).to eq(used_delegated_functions_on - i.day)
      end
    end

    context 'date is just within 12 months ago' do
      let(:used_delegated_functions_on) { today - 12.months + 1.day }

      it 'is valid' do
        expect(subject).to be_valid
      end

      it 'updates the application types reported on date to Today' do
        application_proceeding_types.each_with_index do |type, i|
          expect(type.used_delegated_functions_reported_on).to eq Time.zone.today
          expect(type.used_delegated_functions_on).to eq(used_delegated_functions_on - i.day)
        end
      end
    end

    context 'when delegated functions confirmed' do
      before do
        application_proceeding_types.each do |apt|
          apt.update!(used_delegated_functions_on: original_date, used_delegated_functions_reported_on: original_date)
        end
      end
      let(:default_params) { { confirm_delegated_functions_date: 'true' } }
      let(:original_date) { 35.days.ago.to_date }

      it 'does not change the df dates on the application proceeding types' do
        application_proceeding_types.each do |type|
          expect(type.used_delegated_functions_reported_on).to eq original_date
          expect(type.used_delegated_functions_on).to eq original_date
        end
      end
    end

    context 'when nothing selected' do
      let(:params) { { confirm_delegated_functions_date: '' } }
      let(:error_locale) { 'used_delegated_functions_on.blank' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        message = I18n.t(error_locale, scope: i18n_scope)
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors.first.type).to match(message)
      end
    end

    context 'when dates are invalid' do
      let(:params) { update_proceeding_type_param_dates(month: 15) }
      let(:error_locale) { 'used_delegated_functions_on.date_invalid' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        message = I18n.t(error_locale, scope: i18n_scope, meaning: 'Meaning')
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors.first.type).to match(message)
      end
    end

    context 'date is older than 12 months ago' do
      let(:used_delegated_functions_on) { 13.months.ago }
      let(:error_locale) { 'used_delegated_functions_on.date_not_in_range' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        months = Time.zone.now.ago(12.months).strftime('%d %m %Y')
        message = I18n.t(error_locale, scope: i18n_scope, months: months, meaning: meaning)
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors.first.type).to match(message)
      end
    end

    context 'when occurred on is in future' do
      let(:used_delegated_functions_on) { 1.day.from_now.to_date }
      let(:error_locale) { 'used_delegated_functions_on.date_is_in_the_future' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message for the invalid proceeding date only' do
        message = I18n.t(error_locale, scope: i18n_scope, meaning: meaning)
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors.first.type).to match(message)
      end
    end

    context 'with delegated function selected but without date' do
      let(:params) { update_proceeding_type_param_dates(month: '') }
      let(:error_locale) { 'used_delegated_functions_on.date_invalid' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        message = I18n.t(error_locale, scope: i18n_scope, meaning: meaning)
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors.first.type).to match(message)
      end
    end

    context 'with a partial date' do
      let(:error_locale) { 'used_delegated_functions_on.date_invalid' }
      let(:params) { update_proceeding_type_param_dates(month: '') }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        message = I18n.t(error_locale, scope: i18n_scope, meaning: meaning)
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors.first.type).to match(message)
      end
    end
  end

  describe '#save as draft' do
    before do
      subject.draft = true
      subject.save(params)
      application_proceeding_types.reload
    end

    it 'updates each application proceeding type if they are entered' do
      application_proceeding_types.each_with_index do |type, i|
        expect(type.used_delegated_functions_reported_on).to eq(used_delegated_functions_reported_on)
        expect(type.used_delegated_functions_on).to eq(used_delegated_functions_on - i.day)
      end
    end

    context 'when occurred on is invalid' do
      let(:params) { update_proceeding_type_param_dates(month: 15) }
      let(:error_locale) { 'used_delegated_functions_on.date_invalid' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        message = I18n.t(error_locale, scope: i18n_scope, meaning: 'Meaning')
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors.first.type).to match(message)
      end
    end

    context 'when occurred on is in future' do
      let(:used_delegated_functions_on) { 1.day.from_now.to_date }
      let(:error_locale) { 'used_delegated_functions_on.date_is_in_the_future' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message for the invalid proceeding date only' do
        message = I18n.t(error_locale, scope: i18n_scope, meaning: meaning)
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors.first.type).to match(message)
      end
    end
  end

  def update_proceeding_type_param_dates(month: nil)
    params = default_params
    application_proceedings_by_name.each_with_index do |type, i|
      adjusted_date = used_delegated_functions_on - i.day
      type_params = proceeding_type_date_params(type, adjusted_date, month)
      params = type_params.merge(params)
    end
    params
  end

  def proceeding_type_date_params(type, adjusted_date, month)
    {
      "#{type.name}_used_delegated_functions_on_3i": adjusted_date.day.to_s,
      "#{type.name}_used_delegated_functions_on_2i": month || adjusted_date.month.to_s,
      "#{type.name}_used_delegated_functions_on_1i": adjusted_date.year.to_s
    }
  end
end
