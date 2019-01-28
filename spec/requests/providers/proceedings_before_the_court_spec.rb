require 'rails_helper'

RSpec.describe 'provider proceedings before the court requests', type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:provider) { legal_aid_application.provider }

  describe 'GET providers/proceedings_before_the_court' do
    subject { get providers_legal_aid_application_proceedings_before_the_court_path(legal_aid_application) }

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
      end

      describe 'back link' do
        it 'points to the client has received legal help page' do
          expect(response.body).to have_back_link(providers_legal_aid_application_client_received_legal_help_path(legal_aid_application))
        end
      end
    end
  end

  describe 'PATCH providers/proceedings_before_the_court' do
    subject { patch providers_legal_aid_application_proceedings_before_the_court_path(legal_aid_application), params: params.merge(submit_button) }
    let(:proceedings_before_the_court) { true }
    let(:details_of_proceedings_before_the_court) { Faker::Lorem.paragraph }
    let(:params) do
      {
        merits_assessment: {
          proceedings_before_the_court: proceedings_before_the_court.to_s,
          details_of_proceedings_before_the_court: details_of_proceedings_before_the_court
        }
      }
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      context 'Continue button pressed' do
        let(:submit_button) do
          {
            continue_button: 'Continue'
          }
        end

        it 'updates the record' do
          expect(legal_aid_application.merits_assessment.reload.proceedings_before_the_court).to eq(proceedings_before_the_court)
          expect(legal_aid_application.merits_assessment.reload.details_of_proceedings_before_the_court).to eq(details_of_proceedings_before_the_court)
        end

        # TODO: remove this test and implement next one when next page is known
        it 'returns next page placeholder' do
          expect(response.body).to include('Placeholder: Statement of case')
        end

        # TODO: fix and implement when next page is known
        xit 'redirects to the next page' do
          expect(response).to redirect_to providers_legal_aid_application_xxxx_path(legal_aid_application)
        end
      end

      context 'Save as draft button pressed' do
        let(:submit_button) do
          {
            draft_button: 'Save as draft'
          }
        end

        it 'updates the record' do
          expect(legal_aid_application.merits_assessment.reload.proceedings_before_the_court).to eq(proceedings_before_the_court)
          expect(legal_aid_application.merits_assessment.reload.details_of_proceedings_before_the_court).to eq(details_of_proceedings_before_the_court)
        end

        it 'redirects to provider applications home page' do
          expect(response).to redirect_to providers_legal_aid_applications_path
        end

        context 'invalid params - nothing specified' do
          let(:proceedings_before_the_court) { nil }
          let(:details_of_proceedings_before_the_court) { nil }

          it 'returns http_success' do
            expect(response).to have_http_status(:ok)
          end

          it 'the response includes the error message' do
            expect(response.body).to include(I18n.t('activemodel.errors.models.merits_assessment.attributes.proceedings_before_the_court.blank'))
          end
        end

        context 'invalid params - details missing' do
          let(:proceedings_before_the_court) { true }
          let(:details_of_proceedings_before_the_court) { nil }

          it 'returns http_success' do
            expect(response).to have_http_status(:ok)
          end

          it 'the response includes the error message' do
            expect(response.body).to include(I18n.t('activemodel.errors.models.merits_assessment.attributes.details_of_proceedings_before_the_court.blank'))
          end
        end
      end
    end
  end
end
