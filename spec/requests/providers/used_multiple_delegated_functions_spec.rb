require 'rails_helper'

RSpec.describe Providers::UsedMultipleDelegatedFunctionsController, type: :request, vcr: { cassette_name: 'gov_uk_bank_holiday_api' } do
  let(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceeding_types }
  let(:application_proceeding_types) { legal_aid_application.application_proceeding_types }
  let(:application_proceedings_by_name) { legal_aid_application.application_proceedings_by_name }
  let(:login_provider) { login_as legal_aid_application.provider }

  before do
    login_provider
    subject
  end

  describe 'GET /providers/applications/:legal_aid_application_id/used_multiple_delegated_functions' do
    subject do
      get providers_legal_aid_application_used_multiple_delegated_functions_path(legal_aid_application)
    end

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end

    context 'dynamic date hint text' do
      it 'contains a valid date' do
        hint_text_date = Time.zone.now.ago(5.days).strftime('%d %m %Y')

        subject
        expect(response.body).to include(hint_text_date)
      end
    end

    context '#pre_dwp_check?' do
      it 'returns true' do
        expect(described_class.new.pre_dwp_check?).to be true
      end
    end

    context 'when not authenticated' do
      let(:login_provider) { nil }
      it_behaves_like 'a provider not authenticated'
    end

    context 'previously selected proceedings' do
      before { subject }

      it 'shows selected proceedings for the application' do
        application_proceedings_by_name.each do |type|
          expect(response.body).to include(type.name)
        end
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/used_multiple_delegated_functions' do
    let!(:legal_aid_application) do
      create :legal_aid_application,
             :with_proceeding_types,
             # :with_delegated_functions,
             proceeding_types_count: 2
      # delegated_functions_date: used_delegated_functions_on
    end
    let(:today) { Time.zone.today }
    let(:used_delegated_functions_on) { rand(19).days.ago.to_date }
    let(:default_params) { { none_selected: 'false', delegated_functions: '' } }
    let(:form_params) { update_proceeding_type_param_dates }
    let(:params) do
      {
        legal_aid_applications_used_multiple_delegated_functions_form: form_params
      }
    end
    let(:button_clicked) { {} }
    let(:mocked_email_service) { instance_double(SubmitApplicationReminderService, send_email: {}) }
    let(:mock_deadline) { today + 20.days }
    let(:earliest_df) { legal_aid_application.proceeding_with_earliest_delegated_functions }
    let(:proceeding_type_meaning1) { legal_aid_application.proceeding_types[0].meaning }
    let(:proceeding_type_meaning2) { legal_aid_application.proceeding_types[1].meaning }
    before do
      allow(SubstantiveApplicationDeadlineCalculator).to receive(:call).with(an_instance_of(Date)).and_return(mock_deadline)
      allow(SubmitApplicationReminderService).to receive(:new).with(legal_aid_application).and_return(mocked_email_service)
      patch(
        providers_legal_aid_application_used_multiple_delegated_functions_path(legal_aid_application),
        params: params.merge(button_clicked)
      )
      application_proceeding_types.reload
    end

    it 'updates the application proceeding types delegated functions dates' do
      application_proceeding_types.each_with_index do |apt, i|
        expect(apt.used_delegated_functions_reported_on).to eq(today)
        expect(apt.used_delegated_functions_on).to eq(used_delegated_functions_on - i.days)
      end
    end

    it 'has a delegated function scope limitation' do
      expect(application_proceeding_types.first.delegated_functions_scope_limitation).not_to be_nil
    end

    it 'has a substantive scope limitation' do
      expect(application_proceeding_types.first.substantive_scope_limitation).not_to be_nil
    end

    it 'redirects to the limitations page' do
      expect(response).to redirect_to(providers_legal_aid_application_limitations_path(legal_aid_application))
    end

    it 'updates the substantive application deadline' do
      legal_aid_application.reload
      expect(legal_aid_application.substantive_application_deadline_on).to eq(mock_deadline)
    end

    context 'email reminder service' do
      context 'within a month ago' do
        let(:past) { today - 1.month + 1.day }
        let(:form_params) { update_proceeding_type_param_dates(day: past.day, month: past.month, year: past.year) }

        it 'calls the submit application reminder mailer service' do
          expect(SubmitApplicationReminderService).to have_received(:new).with(legal_aid_application)
        end
      end

      context 'over a month ago' do
        let(:past) { today - 6.weeks }
        let(:form_params) { update_proceeding_type_param_dates(day: past.day, month: past.month, year: past.year) }
        let(:mock_deadline) { 2.days.ago }

        it 'does not call the submit application reminder mailer service' do
          expect(SubmitApplicationReminderService).not_to have_received(:new).with(legal_aid_application)
        end

        it 'redirects to the confirm delegated_functions dates page' do
          expect(response).to redirect_to(providers_legal_aid_application_confirm_multiple_delegated_functions_path(legal_aid_application))
        end
      end
    end

    context 'when not authenticated' do
      let(:login_provider) { nil }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when date incomplete' do
      let(:form_params) { update_proceeding_type_param_dates(month: '') }

      it 'renders show' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays error' do
        expect(response.body).to include('govuk-error-summary')
        expect(response.body).to include(I18n.t("#{base_error_translation}.date_invalid", meaning: proceeding_type_meaning1))
        expect(response.body).to include(I18n.t("#{base_error_translation}.date_invalid", meaning: proceeding_type_meaning2))
      end
    end

    context 'date is not in range' do
      let(:form_params) { update_proceeding_type_param_dates(day: 20, month: 1, year: 2018) }

      it 'renders show' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays error' do
        hint_text_date = Time.zone.now.ago(12.months).strftime('%d %m %Y')

        subject
        expect(response.body).to include(I18n.t("#{base_error_translation}.date_not_in_range", meaning: proceeding_type_meaning1, months: hint_text_date))
      end
    end

    context 'when date contains alpha characters' do
      let(:form_params) { update_proceeding_type_param_dates(month: '5s') }

      it 'renders show' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays error' do
        expect(response.body).to include('govuk-error-summary')
        expect(response.body).to include(I18n.t("#{base_error_translation}.date_invalid", meaning: proceeding_type_meaning1))
        expect(response.body).to include(I18n.t("#{base_error_translation}.date_invalid", meaning: proceeding_type_meaning2))
      end
    end

    context 'when date not entered' do
      let(:form_params) { update_proceeding_type_param_dates(day: '', month: '', year: '') }

      it 'renders show' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays error' do
        expect(response.body).to include('govuk-error-summary')
        expect(response.body).to include(I18n.t("#{base_error_translation}.date_invalid", meaning: proceeding_type_meaning1))
        expect(response.body).to include(I18n.t("#{base_error_translation}.date_invalid", meaning: proceeding_type_meaning2))
      end
    end

    context 'when not using delegated functions' do
      let(:default_params) do
        params = { none_selected: 'true' }
        application_proceedings_by_name.each { |type| params[:"#{type.name}"] = 'false' }
        params
      end

      it 'updates the application' do
        expect(application_proceeding_types.first.used_delegated_functions?).to be false
        application_proceeding_types.each do |type|
          expect(type.used_delegated_functions_reported_on).to be_nil
          expect(type.used_delegated_functions_on).to be_nil
        end
      end

      it 'redirects to the limitations page' do
        expect(response).to redirect_to(providers_legal_aid_application_limitations_path(legal_aid_application))
      end

      it 'does not have a delegated function scope limitation' do
        expect(application_proceeding_types.first.delegated_functions_scope_limitation).to be_nil
      end
    end

    context 'Form submitted using Save as draft button' do
      let(:button_clicked) { { draft_button: 'Save as draft' } }

      it "redirects provider to provider's applications page" do
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it 'updates the application proceeding types delegated functions dates' do
        application_proceeding_types.each_with_index do |type, i|
          expect(type.used_delegated_functions_reported_on).to eq(today)
          expect(type.used_delegated_functions_on).to eq(used_delegated_functions_on - i.day)
        end
      end

      it 'has a delegated function scope limitation' do
        expect(application_proceeding_types.first.delegated_functions_scope_limitation).not_to be_nil
      end

      it 'has a substantive scope limitation' do
        expect(application_proceeding_types.first.substantive_scope_limitation).not_to be_nil
      end

      it 'does not call the submit application reminder mailer service' do
        expect(SubmitApplicationReminderService).not_to have_received(:new).with(legal_aid_application)
      end

      context 'when nothing selected' do
        let(:default_params) do
          params = { none_selected: 'false' }
          application_proceedings_by_name.each { |type| params[:"#{type.name}"] = 'false' }
          params
        end

        it 'still updates the application proceeding types delegated functions dates' do
          application_proceeding_types.each do |type|
            expect(type.used_delegated_functions_reported_on).to be_nil
            expect(type.used_delegated_functions_on).to be_nil
          end
        end

        it 'does not have a delegated function scope limitation' do
          expect(application_proceeding_types.first.delegated_functions_scope_limitation).to be_nil
        end
      end

      context 'when date not entered' do
        let(:form_params) { update_proceeding_type_param_dates(day: '', month: '', year: '') }

        it 'renders show' do
          expect(response).to have_http_status(:ok)
        end

        it 'displays error' do
          expect(response.body).to include('govuk-error-summary')
          expect(response.body).to include(I18n.t("#{base_error_translation}.date_invalid", meaning: proceeding_type_meaning1))
          expect(response.body).to include(I18n.t("#{base_error_translation}.date_invalid", meaning: proceeding_type_meaning2))
        end
      end
    end
  end

  def update_proceeding_type_param_dates(day: nil, month: nil, year: nil)
    params = default_params
    application_proceedings_by_name.each_with_index do |type, i|
      adjusted_date = used_delegated_functions_on - i.day
      type_params = proceeding_type_date_params(type, adjusted_date, day, month, year)
      params = type_params.merge(params)
    end
    params
  end

  def proceeding_type_date_params(type, adjusted_date, day, month, year)
    {
      "#{type.name}": 'true',
      "#{type.name}_used_delegated_functions_on_3i": day || adjusted_date.day.to_s,
      "#{type.name}_used_delegated_functions_on_2i": month || adjusted_date.month.to_s,
      "#{type.name}_used_delegated_functions_on_1i": year || adjusted_date.year.to_s
    }
  end

  def base_error_translation
    'activemodel.errors.models.application_proceeding_types.attributes.used_delegated_functions_on'
  end
end
