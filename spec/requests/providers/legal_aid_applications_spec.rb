require 'rails_helper'

RSpec.describe 'providers legal aid application requests', type: :request do
  describe 'GET /providers/applications' do
    let(:legal_aid_application) { create :legal_aid_application }
    let(:provider) { legal_aid_application.provider }
    let(:other_provider) { create(:provider) }
    let(:other_provider_in_same_firm) { create :provider, firm: provider.firm }
    let(:params) { {} }
    subject { get providers_legal_aid_applications_path(params) }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
      end

      it 'returns http success' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it "includes a link to the legal aid application's default start path" do
        subject
        expect(response.body).to include(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
      end

      context 'when legal_aid_application current path set' do
        let!(:other_provider_in_same_firm) { create :provider, firm: provider.firm }
        let!(:legal_aid_application) { create :legal_aid_application, provider_step: :applicant_details }
        let!(:other_provider_in_same_firm_application) { create :legal_aid_application, provider: other_provider_in_same_firm, provider_step: :applicant_details }
        let!(:other_provider_application) { create :legal_aid_application, provider: other_provider, provider_step: :applicant_details }

        it "includes a link to the legal aid application's current path" do
          subject
          expect(response.body).to include(providers_legal_aid_application_applicant_details_path(legal_aid_application))
        end

        it 'includes a link to the application of the other provider in the same firm' do
          subject
          expect(response.body).to include(providers_legal_aid_application_applicant_details_path(other_provider_in_same_firm_application))
        end

        it 'does not include a link to the application of the provider in a different firm' do
          subject
          expect(response.body).not_to include(providers_legal_aid_application_applicant_details_path(other_provider_application))
        end
      end

      context 'when legal_aid_application current path is unknown' do
        let!(:legal_aid_application) { create :legal_aid_application, provider_step: :unknown }

        it 'links to start of journey' do
          subject
          start_path = Flow::KeyPoint.path_for(
            journey: :providers,
            key_point: :edit_applicant,
            legal_aid_application: legal_aid_application
          )
          expect(response.body).to include(start_path)
        end
      end

      context 'with pagination' do
        it 'shows current total information' do
          subject
          expect(response.body).to include('Showing 1 of 1')
        end

        it 'does not show navigation links' do
          subject
          expect(parsed_response_body.css('.pagination-container nav')).to be_empty
        end

        context 'and more applications than page size' do
          # Creating 4 additional means there are now 5 applications
          let!(:additional_applications) { create_list :legal_aid_application, 4, provider: provider }
          let(:params) { { page_size: 3 } }

          it 'show page information' do
            subject
            expect(response.body).to include('Showing 1 - 3 of 5')
          end

          it 'shows pagination' do
            subject
            expect(parsed_response_body.css('.pagination-container nav').text).to match(/Previous\s+1\s+2\s+Next/)
          end
        end
      end
    end

    context 'when another provider is authenticated' do
      before do
        login_as other_provider
        subject
      end

      it 'displays no results' do
        expect(response.body).to include('No results')
      end
    end
  end

  describe 'POST /providers/applications' do
    subject { post providers_legal_aid_applications_path }
    let(:legal_aid_application) { LegalAidApplication.last }

    context 'when the provider is authenticated' do
      before do
        login_as create(:provider)
      end

      it 'does not create a new application record' do
        expect { subject }.not_to change { LegalAidApplication.count }
      end

      it 'redirects to new applicant page ' do
        subject
        expect(response).to redirect_to(new_providers_applicant_path)
      end
    end
  end
end
