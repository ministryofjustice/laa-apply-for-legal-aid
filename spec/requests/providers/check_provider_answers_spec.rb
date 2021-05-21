require 'rails_helper'

RSpec.describe Providers::CheckProviderAnswersController, type: :request do
  let(:used_delegated_functions) { false }
  let(:used_delegated_functions_on) { nil }
  let(:address) { create :address }
  let(:applicant) { create :applicant, address: address }
  let(:application) do
    create(
      :legal_aid_application,
      :with_non_passported_state_machine,
      :at_entering_applicant_details,
      :with_proceeding_types,
      :with_delegated_functions,
      delegated_functions_date: used_delegated_functions_on,
      applicant: applicant
    )
  end
  let(:application_id) { application.id }
  let(:parsed_html) { Nokogiri::HTML(response.body) }
  let(:used_delegated_functions_answer) { parsed_html.at_css('#app-check-your-answers__used_delegated_functions .govuk-summary-list__value') }
  let(:used_delegated_functions_on_answer) { parsed_html.at_css('#app-check-your-answers__used_delegated_functions_on .govuk-summary-list__value') }

  describe 'GET /providers/applications/:legal_aid_application_id/check_provider_answers' do
    subject { get "/providers/applications/#{application_id}/check_provider_answers" }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as application.provider
        subject
      end

      it 'returns success' do
        expect(response).to be_successful
      end

      context '#pre_dwp_check?' do
        it 'returns true' do
          expect(described_class.new.pre_dwp_check?).to be true
        end
      end

      it 'displays the correct page' do
        expect(unescaped_response_body).to include('Check your answers')
      end

      it 'displays the correct proceeding' do
        expect(unescaped_response_body).to include(application.proceeding_types[0].meaning)
      end

      context 'delegated functions not used' do
        let(:application) do
          create(
            :legal_aid_application,
            :with_non_passported_state_machine,
            :at_entering_applicant_details,
            :with_proceeding_types,
            applicant: applicant
          )
        end

        it 'displays correct used_delegated_functions answer' do
          expect(used_delegated_functions_answer.content.strip).to eq('No')
        end

        it 'does not display used_delegated_functions_on answer' do
          expect(used_delegated_functions_on_answer).to be_nil
        end
      end

      context 'provider have used delegated functions' do
        let(:used_delegated_functions) { true }
        let(:used_delegated_functions_on) { Faker::Date.backward }

        it 'displays correct used_delegated_functions answer' do
          expect(used_delegated_functions_answer.content.strip).to eq('Yes')
        end

        it 'displays correct used_delegated_functions_on answer' do
          expect(used_delegated_functions_on_answer.content.strip).to eq(application.used_delegated_functions_on.to_s.strip)
        end
      end

      describe 'back link' do
        it 'points to the select address page' do
          expect(response.body).to have_back_link(reset_providers_legal_aid_application_check_provider_answers_path(application))
        end
      end

      it 'displays the correct client details' do
        applicant = application.applicant

        expect(unescaped_response_body).to include(applicant.first_name)
        expect(unescaped_response_body).to include(applicant.last_name)
        expect(unescaped_response_body).to include(applicant.date_of_birth.to_s)
        expect(unescaped_response_body).to include(applicant.national_insurance_number)
      end

      it 'formats the address correctly' do
        address = application.applicant.addresses[0]
        expected_answer = "#{address.address_line_one}<br>#{address.address_line_two}<br>#{address.city}<br>#{address.county}<br>#{address.pretty_postcode}"
        expect(unescaped_response_body).to include(expected_answer)
      end

      context 'when an address includes an organisation but no address_line_one' do
        let(:address) { create :address, address_line_one: 'Honeysuckle Cottage', address_line_two: 'Station Road', city: 'Dartford', county: '', postcode: 'DA4 0EN' }
        it 'formats the address correctly' do
          expect(unescaped_response_body).to include('Honeysuckle Cottage<br>Station Road<br>Dartford<br>DA4 0EN')
        end
      end

      context 'when the application is in applicant_entering_means state' do
        before do
          application.state_machine_proxy.update!(aasm_state: :applicant_entering_means)
          get providers_legal_aid_application_check_provider_answers_path(application)
        end

        describe 'back link' do
          it 'points to the applications page' do
            expect(response.body).to have_back_link(providers_legal_aid_applications_path)
          end
        end

        describe 'Back to your applications button' do
          it 'has a back to your applications button' do
            expect(button_value(html_body: response.body, attr: '#continue')).to eq('Back to your applications')
          end
        end

        it 'displays the correct client details' do
          applicant = application.applicant
          address = applicant.addresses[0]

          expect(unescaped_response_body).to include(applicant.first_name)
          expect(unescaped_response_body).to include(applicant.last_name)
          expect(unescaped_response_body).to include(applicant.date_of_birth.to_s)
          expect(unescaped_response_body).to include(applicant.national_insurance_number)
          expect(unescaped_response_body).to include(address.address_line_one)
          expect(unescaped_response_body).to include(address.city)
          expect(unescaped_response_body).to include(address.pretty_postcode)
        end
      end

      context 'when client is checking answers' do
        let(:application) do
          create(:legal_aid_application,
                 :with_proceeding_types,
                 :with_applicant_and_address,
                 :with_substantive_scope_limitation,
                 :with_non_passported_state_machine,
                 :checking_citizen_answers)
        end
        it 'renders page successfully' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when client has completed their journey' do
        let(:application) { create(:legal_aid_application, :with_proceeding_types, :with_applicant_and_address, :with_non_passported_state_machine, :provider_assessing_means) }
        it 'redirects to client completed means page' do
          expect(response).to redirect_to(providers_legal_aid_application_client_completed_means_path(application))
        end
      end
    end
  end

  describe 'POST /providers/applications/:legal_aid_application_id/check_provider_answers/reset' do
    subject { post "/providers/applications/#{application_id}/check_provider_answers/reset" }

    context 'when the provider is authenticated' do
      before do
        login_as application.provider
        application.check_applicant_details!
        get providers_legal_aid_application_proceedings_types_path(application)
        get providers_legal_aid_application_check_provider_answers_path(application)
        subject
      end

      it 'should redirect back' do
        expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(application, back: true))
      end

      it 'should change the stage back to "entering_applicant_details' do
        subject
        expect(application.reload.entering_applicant_details?).to be_truthy
      end
    end
  end

  describe 'PATCH  /providers/applications/:legal_aid_application_id/check_provider_answers/continue' do
    context 'Continue' do
      let(:params) do
        {
          continue_button: 'Continue'
        }
      end

      subject { patch "/providers/applications/#{application_id}/check_provider_answers/continue", params: params }

      before do
        login_as application.provider
        application.check_applicant_details!
      end

      it 'redirects to next step' do
        subject
        expect(response).to redirect_to(providers_legal_aid_application_check_benefits_path(application))
      end

      context 'allow dwp override' do
        before do
          allow(Setting).to receive(:override_dwp_results?).and_return(true)
          subject
        end

        context 'non passported' do
          it 'redirects to the check benefits page' do
            expect(response).to redirect_to(providers_legal_aid_application_check_benefits_path(application))
          end
        end

        context 'passported' do
          let(:application) do
            create(
              :legal_aid_application,
              :with_passported_state_machine,
              :at_entering_applicant_details,
              :with_proceeding_types,
              :with_delegated_functions,
              delegated_functions_date: used_delegated_functions_on,
              applicant: applicant
            )
          end

          it 'redirects to the check benefits page' do
            expect(response).to redirect_to(providers_legal_aid_application_check_benefits_path(application))
          end
        end
      end
    end

    context 'Save as draft' do
      let(:params) do
        {
          draft_button: 'Save as draft'
        }
      end

      subject { patch "/providers/applications/#{application_id}/check_provider_answers/continue", params: params }

      before do
        login_as application.provider
        application.check_applicant_details!
        subject
        application.reload
      end

      it 'redirects to provider legal applications home page' do
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it 'changes the state to "applicant_details_checked"' do
        expect(application).not_to be_applicant_details_checked
      end

      it 'sets application as draft' do
        expect(application).to be_draft
      end
    end
  end
end
