require 'rails_helper'

RSpec.describe Providers::LimitationsController, type: :request do
  # let!(:proceeding_type) { create :proceeding_type }
  # let(:legal_aid_application) { create :legal_aid_application, :with_substantive_scope_limitation, proceeding_types: [proceeding_type] }
  # let(:provider) { legal_aid_application.provider }

  let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types }
  let(:proceeding_type) { legal_aid_application.proceeding_types.first }
  let(:provider) { legal_aid_application.provider }

  describe 'GET /providers/applications/:id/limitations' do
    subject { get providers_legal_aid_application_limitations_path(legal_aid_application) }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
        expect(unescaped_response_body).to include(I18n.t('providers.limitations.legacy_proceeding_types.h1-heading'))
      end
    end

    context 'when the multiple proceedings flag is off' do
      before do
        Setting.setting.update!(allow_multiple_proceedings: false)
        login_as provider
        subject
      end

      it 'shows the correct text' do
        expect(unescaped_response_body).to include(I18n.t('providers.limitations.legacy_proceeding_types.substantive_certificate_covered'))
      end

      it 'does not have a details section' do
        expect(parsed_response_body.css('details')).to be_empty
      end
    end

    context 'when the multiple proceedings flag is on' do
      before do
        Setting.setting.update!(allow_multiple_proceedings: true)
        login_as provider
        subject
      end

      it 'puts scope limitations in a details section' do
        expect(parsed_response_body.css('details').text).to include(I18n.t('providers.limitations.multi_proceeding_types.substantive_certificate'))
      end

      context 'when delegated functions have been used' do
        let!(:legal_aid_application1) { create :legal_aid_application, :with_substantive_scope_limitation, :with_proceeding_types, :with_delegated_functions }

        it 'shows the correct text' do
          puts 1111
          pp legal_aid_application1.used_delegated_functions?
          expect(unescaped_response_body).to include(I18n.t('providers.limitations.multi_proceeding_types_with_df.cost_override_question'))
        end
      end
    end


    context '#pre_dwp_check?' do
      it 'returns true' do
        expect(described_class.new.pre_dwp_check?).to be true
      end
    end
  end

  describe 'PATCH /providers/applications/:id/limitations' do
    subject { patch providers_legal_aid_application_limitations_path(legal_aid_application, params: params) }

    before do
      login_as provider
    end

    context 'with the correct params' do
      let(:params) do
        { legal_aid_application: { emergency_cost_override: false } }
      end

      it 'redirects to next page' do
        expect(subject).to redirect_to(providers_legal_aid_application_check_provider_answers_path(legal_aid_application))
      end
    end

    # context 'with incorrect params' do
    #   let(:params) do
    #     { legal_aid_application: { emergency_cost_override: nil } }
    #   end
    #
    #   it 're-renders the form with the validation errors' do
    #     subject
    #     expect(unescaped_response_body).to include('There is a problem')
    #     expect(response.body).to include('govuk-error-summary')
    #     expect(unescaped_response_body).to include('Please select')
    #   end
    # end
  end
end
