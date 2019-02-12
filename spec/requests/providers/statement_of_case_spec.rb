require 'rails_helper'

RSpec.describe 'provider proceedings before the court requests', type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:provider) { legal_aid_application.provider }
  let(:soc) { nil }
  # let(:soc) { legal_aid_application.create_statement_of_case(statement: 'This is my case statement') }

  describe 'GET providers/proceedings_before_the_court' do
    subject { get providers_legal_aid_application_statement_of_case_path(legal_aid_application) }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        legal_aid_application.statement_of_case = soc
        login_as provider
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'does not display error' do
        expect(response.body).not_to match 'id="statement-error"'
      end

      context 'no statement of case record exists for the application' do
        it 'displays an empty text box' do
          expect(legal_aid_application.statement_of_case).to be nil
          expect(response.body).to have_text_area_with_id_and_content('statement', '')
        end
      end

      context 'statement of case record already exists for the application' do
        let(:soc) { legal_aid_application.create_statement_of_case(statement: 'This is my case statement') }
        it 'displays the details of the statement on the page' do
          expect(response.body).to have_text_area_with_id_and_content('statement', soc.statement)
        end
      end

      describe 'back link' do
        it 'points to the client has received legal help page' do
          subject
          expect(response.body).to have_back_link(providers_legal_aid_application_proceedings_before_the_court_path(legal_aid_application))
        end
      end
    end
  end

  describe 'PATCH providers/proceedings_before_the_court' do
    subject { patch providers_legal_aid_application_statement_of_case_path(legal_aid_application), params: params.merge(submit_button) }
    let(:entered_text) { Faker::Lorem.paragraph(3) }

    let(:params) do
      {
        statement_of_case: {
          statement: entered_text
        }
      }
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      let(:submit_button) { {} }

      it 'updates the record' do
        expect(legal_aid_application.statement_of_case.reload.statement).to eq(entered_text)
      end

      it 'redirects to the next page' do
        expect(response).to redirect_to providers_legal_aid_application_estimated_legal_costs_path(legal_aid_application)
      end

      context 'on error' do
        let(:entered_text) { '' }

        it 'returns http success' do
          expect(response).to have_http_status(:ok)
        end

        it 'displays error' do
          expect(response.body).to match 'id="statement-error"'
        end
      end

      context 'Save as draft' do
        let(:submit_button) { { draft_button: 'Save as draft' } }

        it 'updates the record' do
          expect(legal_aid_application.statement_of_case.reload.statement).to eq(entered_text)
        end

        it 'redirects to provider applications home page' do
          expect(response).to redirect_to providers_legal_aid_applications_path
        end

        context 'nothing specified' do
          let(:entered_text) { '' }

          it 'redirects to provider applications home page' do
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end
      end
    end
  end
end
