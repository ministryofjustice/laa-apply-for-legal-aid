require 'rails_helper'

RSpec.describe LegalAidApplications::UsedMultipleDelegatedFunctionsForm, type: :form, vcr: { cassette_name: 'gov_uk_bank_holiday_api' } do
  let!(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceeding_types, :with_multiple_delegated_functions }
  let(:application_proceeding_types) { legal_aid_application.application_proceeding_types }
  let(:application_proceedings_by_name) { legal_aid_application.application_proceedings_by_name }
  let(:today) { Time.zone.today }
  let(:used_delegated_functions_reported_on) { today }
  let(:used_delegated_functions_on) { rand(19).days.ago.to_date }
  let(:default_params) { { none_selected: 'false' } }
  let(:i18n_scope) { 'activemodel.errors.models.application_proceeding_types.attributes' }
  let(:error_locale) { :defined_in_spec }

  let(:params) { update_proceeding_type_param_dates }

  subject { described_class.call(application_proceedings_by_name) }

  describe '#proceeding_with_earliest_delegated_functions' do
    before do
      subject.save(params)
      application_proceeding_types.reload
    end

    it 'updates the application with earliest delegated functions retrievable off any proceeding' do
      form_df_date = subject.proceeding_with_earliest_delegated_functions.used_delegated_functions_on

      application_proceeding_types.each do |type|
        expect(type.proceeding_with_earliest_delegated_functions.used_delegated_functions_on).to eq(form_df_date)
      end
    end
  end

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

      it 'updates the application types with no reported on date' do
        expect(application_proceeding_types.all.pluck(:used_delegated_functions_on)).to match_array [today - 12.months, today - 12.months + 1.day]
        expect(application_proceeding_types.all.pluck(:used_delegated_functions_reported_on)).to match_array [nil, nil]

        # TODO: replace the below with the above if the below still flickers
        # also, check that this has value... used_delegated_functions_reported_on should always have a value
        # if the used_delegated_functions_on has one

        application_proceeding_types.each_with_index do |type, i|
          expect(type.used_delegated_functions_reported_on).to be_nil
          expect(type.used_delegated_functions_on).to eq(used_delegated_functions_on - i.day)
        end
      end
    end

    context 'when no delegated functions selected' do
      let(:default_params) do
        params = { none_selected: 'true' }
        application_proceedings_by_name.each { |type| params[:"#{type.name}"] = 'false' }
        params
      end

      it 'updates the application proceeding types' do
        expect(application_proceeding_types.first.used_delegated_functions?).to be false
      end

      it 'updates the application proceeding type dates to nil' do
        application_proceeding_types.each do |type|
          expect(type.used_delegated_functions_reported_on).to be_nil
          expect(type.used_delegated_functions_on).to be_nil
        end
      end
    end

    context 'when nothing selected' do
      let(:application_proceedings_by_name) { {} }
      let(:params) { {} }
      let(:error_locale) { 'used_delegated_functions_on.nothing_selected' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        message = I18n.t(error_locale, scope: i18n_scope)
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors[:delegated_functions].join).to match(message)
      end
    end

    context 'when none and proceeding both selected' do
      let(:default_params) { { none_selected: 'true' } }
      let(:error_locale) { 'used_delegated_functions_on.none_and_proceeding_selected' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        message = I18n.t(error_locale, scope: i18n_scope)
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors[:delegated_functions].join).to match(message)
      end
    end

    context 'when dates are invalid' do
      let(:params) { update_proceeding_type_param_dates(month: 15) }
      let(:error_locale) { 'used_delegated_functions_on.date_invalid' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        application_proceedings_by_name.each do |type|
          message = I18n.t(error_locale, scope: i18n_scope, meaning: ProceedingType.find_by(name: type.name).meaning)
          expect(message).not_to match(/^translation missing:/)
          expect(subject.errors[:"#{type.name}_used_delegated_functions_on"].join).to match(message)
        end
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
        application_proceedings_by_name.each do |type|
          message = I18n.t(error_locale, scope: i18n_scope, months: months, meaning: ProceedingType.find_by(name: type.name).meaning)
          expect(message).not_to match(/^translation missing:/)
          expect(subject.errors[:"#{type.name}_used_delegated_functions_on"].join).to match(message)
        end
      end
    end

    context 'when occurred on is in future' do
      let(:used_delegated_functions_on) { 1.day.from_now.to_date }
      let(:error_locale) { 'used_delegated_functions_on.date_is_in_the_future' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message for the invalid proceeding date only' do
        message = I18n.t(error_locale, scope: i18n_scope, meaning: 'Inherent jurisdiction high court injunction')
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors['inherent_jurisdiction_high_court_injunction_used_delegated_functions_on'].join).to match(message)
      end
    end

    context 'with delegated function selected but without date' do
      let(:params) do
        params = default_params
        application_proceedings_by_name.each { |type| params.merge!({ "#{type.name}": 'true' }) }
        params
      end
      let(:error_locale) { 'used_delegated_functions_on.date_invalid' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        application_proceedings_by_name.each do |type|
          message = I18n.t(error_locale, scope: i18n_scope, meaning: ProceedingType.find_by(name: type.name).meaning)
          expect(message).not_to match(/^translation missing:/)
          expect(subject.errors[:"#{type.name}_used_delegated_functions_on"].join).to match(message)
        end
      end
    end

    context 'with a partial date' do
      let(:error_locale) { 'used_delegated_functions_on.date_invalid' }
      let(:params) { update_proceeding_type_param_dates(month: '') }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        application_proceedings_by_name.each do |type|
          message = I18n.t(error_locale, scope: i18n_scope, meaning: ProceedingType.find_by(name: type.name).meaning)
          expect(message).not_to match(/^translation missing:/)
          expect(subject.errors[:"#{type.name}_used_delegated_functions_on"].join).to match(message)
        end
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

    context 'when nothing selected' do
      let(:params) { {} }

      it 'updates the application proceeding types' do
        expect(application_proceeding_types.first.used_delegated_functions?).to be false
      end

      it 'updates the application proceeding type dates to nil' do
        application_proceeding_types.each do |type|
          expect(type.used_delegated_functions_reported_on).to be_nil
          expect(type.used_delegated_functions_on).to be_nil
        end
      end
    end

    context 'when occurred on is invalid' do
      let(:params) { update_proceeding_type_param_dates(month: 15) }
      let(:error_locale) { 'used_delegated_functions_on.date_invalid' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message' do
        application_proceedings_by_name.each do |type|
          message = I18n.t(error_locale, scope: i18n_scope, meaning: ProceedingType.find_by(name: type.name).meaning)
          expect(message).not_to match(/^translation missing:/)
          expect(subject.errors[:"#{type.name}_used_delegated_functions_on"].join).to match(message)
        end
      end
    end

    context 'when occurred on is in future' do
      let(:used_delegated_functions_on) { 1.day.from_now.to_date }
      let(:error_locale) { 'used_delegated_functions_on.date_is_in_the_future' }

      it 'is invalid' do
        expect(subject).to be_invalid
      end

      it 'generates the expected error message for the invalid proceeding date only' do
        message = I18n.t(error_locale, scope: i18n_scope, meaning: 'Inherent jurisdiction high court injunction')
        expect(message).not_to match(/^translation missing:/)
        expect(subject.errors['inherent_jurisdiction_high_court_injunction_used_delegated_functions_on'].join).to match(message)
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
      "#{type.name}": 'true',
      "#{type.name}_used_delegated_functions_on_3i": adjusted_date.day.to_s,
      "#{type.name}_used_delegated_functions_on_2i": month || adjusted_date.month.to_s,
      "#{type.name}_used_delegated_functions_on_1i": adjusted_date.year.to_s
    }
  end
end
