require "rails_helper"

RSpec.describe Providers::CheckProviderAnswersController do
  let(:application) do
    create(
      :legal_aid_application,
      :with_non_passported_state_machine,
      :at_entering_applicant_details,
      :with_proceedings,
      applicant:,
      partner:,
      set_lead_proceeding: :da001,
    )
  end

  let(:applicant) { create(:applicant, :with_address) }
  let(:application_id) { application.id }
  let(:parsed_html) { Nokogiri::HTML(response.body) }
  let(:proceeding_name) { application.lead_proceeding.name }
  let(:used_delegated_functions_answer) { parsed_html.at_css("#app-check-your-answers__#{proceeding_name}_used_delegated_functions_on .govuk-summary-list__value") }
  let(:partner) { nil }
  let(:pma_flag) { true }

  before { allow(Setting).to receive(:partner_means_assessment?).and_return(pma_flag) }

  describe "GET /providers/applications/:legal_aid_application_id/check_provider_answers" do
    subject { get "/providers/applications/#{application_id}/check_provider_answers" }

    context "when the provider is not authenticated" do
      before { subject }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as application.provider
        subject
      end

      it "returns success" do
        expect(response).to be_successful
      end

      it "displays the correct page" do
        expect(unescaped_response_body).to include("Check your answers")
      end

      context "delegated functions not used" do
        let(:application) do
          create(
            :legal_aid_application,
            :with_non_passported_state_machine,
            :at_entering_applicant_details,
            :with_proceedings,
            applicant:,
          )
        end

        it "displays correct used_delegated_functions answer" do
          expect(used_delegated_functions_answer.content.strip).to eq("Not used")
        end
      end

      context "provider has used delegated functions" do
        let(:application) do
          create(
            :legal_aid_application,
            :with_non_passported_state_machine,
            :at_entering_applicant_details,
            :with_proceedings,
            :with_delegated_functions_on_proceedings,
            explicit_proceedings: [:da004],
            set_lead_proceeding: :da004,
            df_options: { DA004: [Time.zone.today, Time.zone.today] },
            applicant:,
          )
        end

        before do
          application.reload
        end

        it "displays correct used_delegated_functions_on answer" do
          expect(used_delegated_functions_answer.content.strip).to eq(application.used_delegated_functions_on.to_fs.strip)
        end
      end

      describe "back link" do
        it "points to the select address page" do
          expect(response.body).to have_back_link(reset_providers_legal_aid_application_check_provider_answers_path(application))
        end
      end

      it "displays the correct client details" do
        applicant = application.applicant

        expect(unescaped_response_body).to include(applicant.first_name)
        expect(unescaped_response_body).to include(applicant.last_name)
        expect(unescaped_response_body).to include(applicant.date_of_birth.to_s)
        expect(unescaped_response_body).to include(applicant.national_insurance_number)
        expect(unescaped_response_body).to include("Does your client have a partner?")
      end

      it "formats the address correctly" do
        address = application.applicant.addresses[0]
        expected_answer = "#{address.address_line_one}<br>#{address.address_line_two}<br>#{address.city}<br>#{address.county}<br>#{address.pretty_postcode}"
        expect(unescaped_response_body).to include(expected_answer)
      end

      context "when an address includes an organisation but no address_line_one" do
        let(:address) { create(:address, address_line_one: "Honeysuckle Cottage", address_line_two: "Station Road", city: "Dartford", county: "", postcode: "DA4 0EN") }
        let(:applicant) { create(:applicant, address:) }

        it "formats the address correctly" do
          expect(unescaped_response_body).to include("Honeysuckle Cottage<br>Station Road<br>Dartford<br>DA4 0EN")
        end
      end

      context "when the application is in applicant_entering_means state" do
        before do
          application.state_machine_proxy.update!(aasm_state: :applicant_entering_means)
          get providers_legal_aid_application_check_provider_answers_path(application)
        end

        describe "back link" do
          it "points to the applications page" do
            expect(response.body).to have_back_link(providers_legal_aid_applications_path)
          end
        end

        describe "Back to your applications button" do
          it "has a back to your applications button" do
            expect(button_value(html_body: response.body, attr: "#continue")).to eq("Back to your applications")
          end
        end

        it "displays the correct client details" do
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

      context "when client is checking answers" do
        let(:application) do
          create(:legal_aid_application,
                 :with_proceedings,
                 :with_applicant_and_address,
                 :with_non_passported_state_machine,
                 :checking_citizen_answers)
        end

        it "renders page successfully" do
          expect(response).to have_http_status(:ok)
        end
      end

      context "when client has completed their journey" do
        let(:application) { create(:legal_aid_application, :with_proceedings, :with_applicant_and_address, :with_non_passported_state_machine, :provider_assessing_means) }

        it "redirects to client completed means page" do
          expect(response).to redirect_to(providers_legal_aid_application_client_completed_means_path(application))
        end
      end

      context "when the client has a partner" do
        let(:applicant) { create(:applicant, :with_address, :with_partner) }
        let(:partner) { create(:partner) }

        it "renders the partner block" do
          expect(unescaped_response_body).to include("Partner's details")
          expect(unescaped_response_body).to include(partner.first_name)
          expect(unescaped_response_body).to include(partner.last_name)
          expect(unescaped_response_body).to include(partner.date_of_birth.to_s)
          expect(unescaped_response_body).to include(partner.national_insurance_number)
        end
      end

      context "when the partner_means_assessment feature flag is off" do
        let(:pma_flag) { false }

        it "does not show the client has partner section" do
          expect(unescaped_response_body).not_to include("Does your client have a partner?")
        end
      end
    end
  end

  describe "POST /providers/applications/:legal_aid_application_id/check_provider_answers/reset", :vcr do
    subject { post "/providers/applications/#{application_id}/check_provider_answers/reset" }

    context "when the provider is authenticated" do
      before do
        login_as application.provider
        application.check_applicant_details!
        get providers_legal_aid_application_proceedings_types_path(application)
        get providers_legal_aid_application_check_provider_answers_path(application)
        subject
      end

      it "redirects back" do
        expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(application, back: true))
      end

      it 'changes the stage back to "entering_applicant_details' do
        subject
        expect(application.reload).to be_entering_applicant_details
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/check_provider_answers/continue" do
    shared_examples "age_for_means_test_purposes updater" do
      it "updates age_for_means_test_purposes" do
        expect { request }.to change { applicant.reload.age_for_means_test_purposes }.from(nil).to(instance_of(Integer))
      end
    end

    context "when Continue clicked" do
      subject(:request) { patch "/providers/applications/#{application_id}/check_provider_answers/continue", params: }

      let(:params) do
        {
          continue_button: "Continue",
        }
      end

      before do
        login_as application.provider
        application.check_applicant_details!
      end

      it_behaves_like "age_for_means_test_purposes updater"

      shared_examples "non means tested flow" do
        it "redirects to no means test required confirmation page" do
          request
          expect(response).to redirect_to(providers_legal_aid_application_confirm_non_means_tested_applications_path(application))
        end

        it "marks application as non means tested" do
          expect { request }.to change { application.reload.non_means_tested? }.from(false).to(true)
        end
      end

      shared_examples "under 16 blocked flow" do
        it "redirects to use CCMS interruption page" do
          request
          expect(response).to redirect_to(providers_legal_aid_application_use_ccms_under16s_path(application))
        end

        it "marks application as under 16s blocked" do
          expect { request }.to change { application.reload.under_16_blocked? }.from(false).to(true)
        end
      end

      context "when passported with no benefit_check_result (default)" do
        let(:application) do
          create(
            :legal_aid_application,
            :at_entering_applicant_details,
            :with_proceedings,
            applicant:,
            set_lead_proceeding: :da001,
          )
        end

        it "redirects to check benefits page" do
          request
          expect(response).to redirect_to(providers_legal_aid_application_check_benefits_path(application))
        end
      end

      context "when already non passported with negative benefit_check_result" do
        it "redirects to the check benefits page" do
          request
          expect(response).to redirect_to(providers_legal_aid_application_check_benefits_path(application))
        end

        context "with MTR phase one enabled and applicant under 18" do
          before { allow(Setting).to receive(:means_test_review_phase_one?).and_return(true) }

          let(:applicant) { create(:applicant, :under_18) }

          it_behaves_like "non means tested flow"

          it "switches to non means tested state machine" do
            expect { request }.to change { application.reload.state_machine }.from(NonPassportedStateMachine).to(NonMeansTestedStateMachine)
          end

          it "switches the non passported check" do
            expect { request }.to change { application.reload.non_passported? }.from(true).to(false)
          end
        end

        context "with MTR phase one enabled and applicant under 18 on earliest date delegated functions used" do
          before { allow(Setting).to receive(:means_test_review_phase_one?).and_return(true) }

          let(:application) do
            create(:legal_aid_application,
                   :with_non_passported_state_machine,
                   :at_entering_applicant_details,
                   :with_proceedings,
                   explicit_proceedings: %i[da001 se013],
                   set_lead_proceeding: :da001,
                   applicant:).tap do |laa|
              laa.proceedings
                .find_by(ccms_code: "DA001")
                .update!(used_delegated_functions: true,
                         used_delegated_functions_on: 7.days.ago,
                         used_delegated_functions_reported_on: Date.current)

              laa.proceedings
                .find_by(ccms_code: "SE013")
                .update!(used_delegated_functions: true,
                         used_delegated_functions_on: 1.day.ago,
                         used_delegated_functions_reported_on: Date.current)
            end
          end

          let(:applicant) { create(:applicant, :under_18_as_of, as_of: 7.days.ago) }

          it_behaves_like "non means tested flow"
        end
      end

      context "when already passported with positive benefit_check_result" do
        let(:application) do
          create(
            :legal_aid_application,
            :with_passported_state_machine,
            :at_entering_applicant_details,
            :with_proceedings,
            applicant:,
          )
        end

        it "redirects to the check benefits page" do
          request
          expect(response).to redirect_to(providers_legal_aid_application_check_benefits_path(application))
        end

        context "with MTR phase one enabled and applicant under 18" do
          before { allow(Setting).to receive(:means_test_review_phase_one?).and_return(true) }

          let(:applicant) { create(:applicant, :under_18) }

          it_behaves_like "non means tested flow"

          it "switches to non means tested state machine" do
            expect { request }.to change { application.reload.state_machine }.from(PassportedStateMachine).to(NonMeansTestedStateMachine)
          end
        end

        context "with MTR phse one enabled and applicant under 16" do
          before { allow(Setting).to receive(:means_test_review_phase_one?).and_return(true) }

          let(:applicant) { create(:applicant, :under_16) }

          it_behaves_like "under 16 blocked flow"
        end

        context "with MTR phse one disabled and applicant under 16" do
          before { allow(Setting).to receive(:means_test_review_phase_one?).and_return(false) }

          let(:applicant) { create(:applicant, :under_16) }

          it_behaves_like "under 16 blocked flow"
        end
      end

      context "when no national insurance number provided and no benefit_check_result" do
        let(:application) do
          create(
            :legal_aid_application,
            :at_entering_applicant_details,
            :with_proceedings,
            applicant:,
          )
        end

        let(:applicant) { create(:applicant, national_insurance_number: nil) }

        it "redirects to the no national insurance number page" do
          request
          expect(response).to redirect_to(providers_legal_aid_application_no_national_insurance_number_path(application))
        end

        context "with MTR phase one enabled and applicant under 18" do
          before { allow(Setting).to receive(:means_test_review_phase_one?).and_return(true) }

          let(:applicant) { create(:applicant, :under_18) }

          it_behaves_like "non means tested flow"

          it "switches to non means tested state machine" do
            expect { request }.to change { application.reload.state_machine }.from(PassportedStateMachine).to(NonMeansTestedStateMachine)
          end
        end

        context "with MTR phase one enabled and applicant under 16" do
          before { allow(Setting).to receive(:means_test_review_phase_one?).and_return(true) }

          let(:applicant) { create(:applicant, :under_16) }

          it_behaves_like "under 16 blocked flow"
        end

        context "with MTR phase one disabled and applicant under 16" do
          before { allow(Setting).to receive(:means_test_review_phase_one?).and_return(false) }

          let(:applicant) { create(:applicant, :under_16) }

          it_behaves_like "under 16 blocked flow"
        end
      end
    end

    context "When Save as draft clicked" do
      subject(:request) { patch "/providers/applications/#{application_id}/check_provider_answers/continue", params: }

      let(:params) do
        {
          draft_button: "Save as draft",
        }
      end

      before do
        login_as application.provider
        application.check_applicant_details!
      end

      it_behaves_like "age_for_means_test_purposes updater"

      it "redirects to provider legal applications home page" do
        request
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it "does not change the state to \"applicant_details_checked\"" do
        expect { request }.not_to change { application.reload.state }.from("checking_applicant_details")
      end

      it "sets application as draft" do
        expect { request }.to change { application.reload.draft? }.from(false).to(true)
      end
    end
  end
end
