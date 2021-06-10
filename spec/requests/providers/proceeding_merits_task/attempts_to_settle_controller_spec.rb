require 'rails_helper'

RSpec.describe Providers::ProceedingMeritsTask::AttemptsToSettleController, type: :request do
  let(:pt_da) { create :proceeding_type, :with_real_data }
  let(:pt_s8) { create :proceeding_type, :as_section_8_child_residence }
  let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, explicit_proceeding_types: [pt_da, pt_s8] }
  let(:application_proceeding_type) { legal_aid_application.application_proceeding_types.find_by(proceeding_type_id: proceeding_type) }
  let(:proceeding_type) { ProceedingType.find_by(ccms_code: 'SE014') }
  let(:smtl) { create :legal_framework_merits_task_list, legal_aid_application: legal_aid_application }
  let(:provider) { legal_aid_application.provider }

  describe 'GET /providers/applications/merits_task_list/:merits_task_list_id/attempts_to_settle' do
    subject { get providers_merits_task_list_attempts_to_settle_path(application_proceeding_type) }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
        login_as provider
      end

      it 'returns http success' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'displays the correct proceeding type as a header' do
        subject
        expect(unescaped_response_body).to include(application_proceeding_type.proceeding_type.meaning)
      end
    end
  end

  describe 'PATCH /providers/merits_task_list/:merits_task_list_id/attempts_to_settle' do
    let(:params) do
      {
        proceeding_merits_task_attempts_to_settle: {
          attempts_made: 'Details of settlement attempt',
          application_proceeding_type_id: application_proceeding_type.id
        }
      }
    end

    context 'when the provider is authenticated' do
      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
        login_as provider
      end

      subject do
        patch providers_merits_task_list_attempts_to_settle_path(application_proceeding_type), params: params.merge(submit_button)
      end

      context 'Form submitted using Continue button' do
        let(:submit_button) { { continue_button: 'Continue' } }

        it 'redirects provider back to the merits task list' do
          subject
          expect(response).to redirect_to(providers_legal_aid_application_merits_task_list_path(legal_aid_application))
        end

        context 'when the application is in draft' do
          let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :draft, explicit_proceeding_types: [pt_da, pt_s8] }

          it 'redirects provider back to the merits task list' do
            subject
            expect(response).to redirect_to(providers_legal_aid_application_merits_task_list_path(legal_aid_application))
          end

          it 'sets the application as no longer draft' do
            expect { subject }.to change { legal_aid_application.reload.draft? }.from(true).to(false)
          end
        end

        context 'when the multi-proceeding flag is true' do
          before { allow(Setting).to receive(:allow_multiple_proceedings?).and_return(true) }

          it 'updates the task list' do
            subject
            expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :attempts_to_settle\n\s+dependencies: \*\d\n\s+state: :complete/)
          end
        end

        context 'when the params are not valid' do
          let(:params) { { proceeding_merits_task_attempts_to_settle: { attempts_made: '' } } }

          it 'renders the form page displaying the errors' do
            subject

            expect(unescaped_response_body).to include('There is a problem')
            expect(unescaped_response_body).to include('Please provide details of the attempts made to settle')
          end
        end
      end

      context 'Form submitted using Save as draft button' do
        let(:submit_button) { { draft_button: 'Save as draft' } }

        subject do
          patch providers_merits_task_list_attempts_to_settle_path(application_proceeding_type), params: params.merge(submit_button)
        end

        it "redirects provider to provider's applications page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it 'sets the application as draft' do
          expect { subject }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
        end

        context 'when the multi-proceeding flag is true' do
          before { allow(Setting).to receive(:allow_multiple_proceedings?).and_return(true) }

          it 'does not set the task to complete' do
            subject
            expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to_not match(/name: :attempts_to_settle\n\s+dependencies: \*\d\n\s+state: :complete/)
          end
        end
      end
    end
  end
end
