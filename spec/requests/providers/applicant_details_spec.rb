require 'rails_helper'

RSpec.describe Providers::ApplicantDetailsController, type: :request do
  let(:application) { create(:legal_aid_application) }
  let(:application_id) { application.id }
  let(:provider) { application.provider }

  describe 'GET /providers/applications/:legal_aid_application_id/applicant_details' do
    subject { get "/providers/applications/#{application_id}/applicant_details" }

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

      context 'has already got applicant info' do
        let(:applicant) { create(:applicant) }
        let(:application) { create(:legal_aid_application, applicant: applicant) }

        it 'display first_name' do
          subject
          expect(unescaped_response_body).to include(applicant.first_name)
        end
      end

      context '#pre_dwp_check?' do
        it 'returns true' do
          expect(described_class.new.pre_dwp_check?).to be true
        end
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/applicant_details' do
    let(:params) do
      {
        applicant: {
          first_name: 'John',
          last_name: 'Doe',
          national_insurance_number: 'AA 12 34 56 C',
          'date_of_birth(1i)': '1981',
          'date_of_birth(2i)': '07',
          'date_of_birth(3i)': '11',
          email: Faker::Internet.safe_email
        }
      }
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
      end

      subject do
        patch providers_legal_aid_application_applicant_details_path(application), params: params
      end

      context 'Form submitted using Continue button' do
        let(:submit_button) do
          {
            continue_button: 'Continue'
          }
        end

        it 'redirects provider to next step of the submission' do
          subject
          expect(response).to redirect_to(providers_legal_aid_application_address_lookup_path(application))
        end

        it 'creates a new applicant associated with the application' do
          expect { subject }.to change { Applicant.count }.by(1)

          new_applicant = application.reload.applicant
          expect(new_applicant).to be_instance_of(Applicant)
        end

        context 'when the application is in draft' do
          let(:application) { create(:legal_aid_application, :draft) }

          it 'redirects provider to next step of the submission' do
            subject
            expect(response).to redirect_to(providers_legal_aid_application_address_lookup_path(application))
          end

          it 'sets the application as no longer draft' do
            expect { subject }.to change { application.reload.draft? }.from(true).to(false)
          end
        end

        context 'when the legal aid application is in checking_applicant_details state' do
          let(:application) { create(:legal_aid_application, :checking_applicant_details) }

          it 'redirects to check_your_answers page' do
            subject

            expect(response).to redirect_to(providers_legal_aid_application_check_provider_answers_path)
          end
        end

        context 'when the application is in applicant_details_checked state' do
          let(:application) { create(:legal_aid_application, :applicant_details_checked) }

          it 'redirects to check_your_answers page' do
            subject
            expect(response).to redirect_to(providers_legal_aid_application_check_provider_answers_path)
          end
        end

        context 'when the params are not valid' do
          let(:params) do
            {
              applicant: {
                first_name: '',
                last_name: 'Doe',
                national_insurance_number: 'AA 12 34 56 C',
                'date_of_birth(1i)': '1981',
                'date_of_birth(2i)': '07',
                'date_of_birth(3i)': '11',
                email: Faker::Internet.safe_email
              }
            }
          end

          it 'renders the form page displaying the errors' do
            subject

            expect(unescaped_response_body).to include('There is a problem')
            expect(unescaped_response_body).to include('Enter first name')
          end

          it 'does NOT create a new applicant' do
            expect { subject }.not_to change { Applicant.count }
          end
        end
      end

      context 'Form submitted using Save as draft button' do
        let(:submit_button) { { draft_button: 'Save as draft' } }

        subject do
          patch providers_legal_aid_application_applicant_details_path(application), params: params.merge(submit_button)
        end

        it "redirects provider to provider's applications page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it 'sets the application as draft' do
          expect { subject }.to change { application.reload.draft? }.from(false).to(true)
        end
      end

      context 'dates contain alpha characters' do
        let(:params) do
          {
            applicant: {
              first_name: '',
              last_name: 'Doe',
              national_insurance_number: 'AA 12 34 56 C',
              'date_of_birth(1i)': '1981',
              'date_of_birth(2i)': '6s',
              'date_of_birth(3i)': '11sa',
              email: Faker::Internet.safe_email
            }
          }
        end

        it 'errors' do
          subject
          expect(unescaped_response_body).to include('There is a problem')
          expect(unescaped_response_body).to include('Enter a valid date of birth')
        end
      end
    end
  end
end
