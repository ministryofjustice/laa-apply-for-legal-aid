require 'rails_helper'

RSpec.describe 'provider restrictions request', type: :request do
  let(:application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine }
  let(:provider) { application.provider }

  describe 'GET /providers/applications/:id/restrictions' do
    subject { get providers_legal_aid_application_restrictions_path(application) }

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
    end
  end

  describe 'PATCH /providers/applications/:id/restrictions' do
    subject { patch providers_legal_aid_application_restrictions_path(application), params: params.merge(submit_button) }
    let(:params) do
      {
        legal_aid_application: {
          has_restrictions: has_restrictions,
          restrictions_details: restrictions_details
        }
      }
    end
    let(:restrictions_details) { Faker::Lorem.paragraph }
    let(:has_restrictions) { 'true' }

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      context 'Form submitted with continue button' do
        let(:submit_button) do
          {
            continue_button: 'Continue'
          }
        end

        it 'updates legal aid application restriction information' do
          expect(application.reload.has_restrictions).to eq true
          expect(application.reload.restrictions_details).to_not be_empty
        end

        context 'when the citizen has completed the non-passported path' do
          context 'and the calculation date is after the start date' do
            let(:application) do
              create :legal_aid_application,
                     :with_applicant,
                     :non_passported,
                     :with_non_passported_state_machine,
                     :provider_assessing_means,
                     :with_proceeding_types,
                     :with_delegated_functions,
                     delegated_functions_reported_date: Date.new(2021, 1, 9)
            end

            it 'redirects to policy disregards' do
              expect(response).to redirect_to(providers_legal_aid_application_policy_disregards_path(application))
            end
          end

          context 'and the calculation date is before the start date' do
            let(:application) do
              create :legal_aid_application,
                     :with_applicant,
                     :non_passported,
                     :with_non_passported_state_machine,
                     :provider_assessing_means,
                     :with_proceeding_types,
                     :with_delegated_functions,
                     delegated_functions_date: Date.new(2020, 12, 19)
            end

            it 'redirects to check passported answers' do
              expect(response).to redirect_to(providers_legal_aid_application_means_summary_path(application))
            end
          end
        end

        context 'provider on passported route' do
          let(:application) { create :legal_aid_application, :with_applicant, :passported, :with_passported_state_machine, :checking_passported_answers }
          it 'redirects to check passported answers' do
            expect(response).to redirect_to(providers_legal_aid_application_check_passported_answers_path(application))
          end
        end

        context 'invalid params' do
          let(:restrictions_details) { '' }

          it 'displays error' do
            expect(response.body).to include(translation_for(:restrictions_details, 'blank'))
          end

          context 'no params' do
            let(:has_restrictions) { '' }

            it 'displays error' do
              expect(response.body).to include(translation_for(:has_restrictions, 'blank'))
            end
          end
        end

        context 'provider checking their answers' do
          let(:application) { create :legal_aid_application, :with_applicant, :with_passported_state_machine, :checking_passported_answers }

          it 'redirects to check passported answers' do
            expect(response).to redirect_to(providers_legal_aid_application_check_passported_answers_path)
          end
        end

        context "provider checking citizen's answers" do
          let(:application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, :checking_non_passported_means }

          it 'redirects to means summary page' do
            subject
            expect(response).to redirect_to(providers_legal_aid_application_means_summary_path)
          end
        end
      end

      context 'Form submitted with Save as draft button' do
        let(:submit_button) do
          {
            draft_button: 'Save as draft'
          }
        end

        context 'after success' do
          before do
            login_as provider
            subject
            application.reload
          end

          it 'updates the legal_aid_application.restrictions' do
            expect(application.has_restrictions).to eq true
            expect(application.restrictions_details).to_not be_empty
          end

          it 'redirects to the list of applications' do
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end
      end
    end
  end

  def translation_for(attr, error)
    I18n.t("activemodel.errors.models.legal_aid_application.attributes.#{attr}.providers.#{error}")
  end
end
