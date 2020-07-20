require 'rails_helper'

RSpec.describe 'providers shared ownership request test', type: :request do
  let!(:legal_aid_application) { create :legal_aid_application, :with_own_home_mortgaged }

  describe 'GET #/providers/applications/:legal_aid_application_id/shared_ownership' do
    subject { get providers_legal_aid_application_shared_ownership_path(legal_aid_application) }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as legal_aid_application.provider
      end

      it 'returns http success' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'renders the shared ownership page' do
        subject
        expect(response).to be_successful
        expect(unescaped_response_body).to match('Does your client own their home with anyone else?')
        expect(unescaped_response_body).to match(LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.first)
      end

      describe 'back link' do
        context 'applicant owns with mortgage' do
          before { get providers_legal_aid_application_outstanding_mortgage_path(legal_aid_application) }

          it 'points to oustanding mortgage page' do
            subject
            expect(response.body).to have_back_link(providers_legal_aid_application_outstanding_mortgage_path(legal_aid_application, back: true))
          end
        end

        context 'applicant owns home outright' do
          before { get providers_legal_aid_application_property_value_path(legal_aid_application) }

          it 'points to the property value page' do
            subject
            expect(response.body).to have_back_link(providers_legal_aid_application_property_value_path(legal_aid_application, back: true))
          end
        end
      end
    end
  end

  describe 'PATCH #/providers/applications/:legal_aid_application_id/shared_ownership' do
    let(:params) do
      {
        legal_aid_application: {
          shared_ownership: shared_ownership
        }
      }
    end

    subject do
      patch providers_legal_aid_application_shared_ownership_path(legal_aid_application), params: params.merge(submit_button)
    end

    context 'when the provider is authenticated' do
      before do
        login_as legal_aid_application.provider
      end

      context 'Submitted with Continue button' do
        let(:submit_button) do
          {
            continue_button: 'Continue'
          }
        end

        context 'Yes path' do
          let!(:shared_ownership) { LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.first }
          it 'does NOT create an new application record' do
            expect { subject }.not_to change { LegalAidApplication.count }
          end

          it 'redirects to the percentage page' do
            subject
            expect(response).to redirect_to providers_legal_aid_application_percentage_home_path(legal_aid_application)
          end

          it 'update legal_aid_application record' do
            expect(legal_aid_application.shared_ownership).to eq nil
            subject
            expect(legal_aid_application.reload.shared_ownership).to eq shared_ownership
          end

          context 'while checking answers' do
            let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :checking_passported_answers }

            it 'redirects to the next step in flow' do
              subject
              expect(response).to redirect_to providers_legal_aid_application_percentage_home_path(legal_aid_application)
            end
          end
        end

        context 'No path' do
          let!(:shared_ownership) { LegalAidApplication::SHARED_OWNERSHIP_NO_REASONS.first }
          it 'does NOT create an new application record' do
            expect { subject }.not_to change { LegalAidApplication.count }
          end

          it 'redirects to the vehicles page' do
            subject
            expect(response).to redirect_to providers_legal_aid_application_vehicle_path(legal_aid_application)
          end

          it 'update legal_aid_application record' do
            expect(legal_aid_application.shared_ownership).to eq nil
            subject
            expect(legal_aid_application.reload.shared_ownership).to eq shared_ownership
            expect(legal_aid_application.percentage_home).to eq 100.0
          end

          context 'while checking answers' do
            let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_passported_state_machine, :checking_passported_answers }

            it 'redirects to check answers page' do
              subject
              expect(response).to redirect_to providers_legal_aid_application_restrictions_path(legal_aid_application)
            end
          end
        end

        context 'with an invalid param' do
          let(:params) { { legal_aid_application: { shared_ownership: '' } } }
          it 're-renders the form with the validation errors' do
            subject
            expect(unescaped_response_body).to include('There is a problem')
            expect(unescaped_response_body).to include('Select yes if your client owns their home with anyone else')
            expect(unescaped_response_body).to include('Does your client own their home with anyone else?')
          end
        end
      end

      context 'submitted with a Save as Draft button' do
        let(:submit_button) do
          {
            draft_button: 'Save as draft'
          }
        end

        context 'Yes path' do
          let!(:shared_ownership) { LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.first }
          it 'does NOT create an new application record' do
            expect { subject }.not_to change { LegalAidApplication.count }
          end

          it 'redirects to the providers applications page' do
            subject
            expect(response).to redirect_to providers_legal_aid_applications_path
          end

          it 'update legal_aid_application record' do
            expect(legal_aid_application.shared_ownership).to eq nil
            subject
            expect(legal_aid_application.reload.shared_ownership).to eq shared_ownership
          end

          context 'while checking answers' do
            let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :checking_passported_answers }

            it 'redirects to the applications list page' do
              subject
              expect(response).to redirect_to(providers_legal_aid_applications_path)
            end
          end
        end

        context 'No path' do
          let!(:shared_ownership) { LegalAidApplication::SHARED_OWNERSHIP_NO_REASONS.first }
          it 'does NOT create an new application record' do
            expect { subject }.not_to change { LegalAidApplication.count }
          end

          it 'redirects to the savings and investments page' do
            subject
            expect(response).to redirect_to providers_legal_aid_applications_path
          end

          it 'update legal_aid_application record' do
            expect(legal_aid_application.shared_ownership).to eq nil
            subject
            expect(legal_aid_application.reload.shared_ownership).to eq shared_ownership
          end

          context 'while checking answers' do
            let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :checking_passported_answers }

            it 'redirects to the applications list page' do
              subject
              expect(response).to redirect_to(providers_legal_aid_applications_path)
            end
          end
        end

        context 'with an empty entry' do
          let(:params) { { legal_aid_application: { shared_ownership: '' } } }
          it 'redirects to the applications list page' do
            subject
            expect(response).to redirect_to(providers_legal_aid_applications_path)
          end
        end
      end
    end
  end
end
