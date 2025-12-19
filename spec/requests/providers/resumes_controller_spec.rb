require "rails_helper"

RSpec.describe Providers::ResumesController do
  describe "GET /providers/applications/:id/resume" do
    subject(:request) { get providers_legal_aid_application_resume_path(application) }

    let(:application) do
      create(:application,
             :with_everything,
             :with_proceedings,
             :with_chances_of_success,
             :with_attempts_to_settle,
             :with_involved_children,
             :with_cfe_v5_result,
             :provider_entering_merits,
             proceeding_count: 3)
    end
    let(:provider) { application.provider }

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      it "returns http redirect" do
        request
        expect(response).to have_http_status(:redirect)
      end

      it "incoming_transactions should return the right URL with param" do
        application.update!(provider_step: "incoming_transactions", provider_step_params: { transaction_type: :pension })
        request
        expect(response).to redirect_to("/providers/applications/#{application.id}/incoming_transactions/pension?locale=en")
      end

      it "outgoing_transactions should return the right URL with param" do
        application.update!(provider_step: "outgoing_transactions", provider_step_params: { transaction_type: :pension })
        request
        expect(response).to redirect_to("/providers/applications/#{application.id}/outgoing_transactions/pension?locale=en")
      end

      context "when saved as draft and amending involved child" do
        it do
          application.update!(provider_step: "involved_children", provider_step_params: { id: "21983d92-876d-4f95-84df-1af2e3308fd7" })
          request
          expect(response).to redirect_to("/providers/applications/#{application.id}/involved_children/21983d92-876d-4f95-84df-1af2e3308fd7?locale=en")
        end
      end

      context "when saved as draft and returning to a started involved child" do
        let(:partial_record) { create(:involved_child, legal_aid_application: application, date_of_birth: nil) }

        it do
          application.update!(provider_step: "involved_children", provider_step_params: { application_merits_task_involved_child: { full_name: partial_record.full_name }, id: "new" })
          request
          expect(response).to redirect_to("/providers/applications/#{application.id}/involved_children/#{partial_record.id}?locale=en")
        end
      end

      context "when saved as draft and adding a new involved child" do
        it do
          application.update!(provider_step: "involved_children", provider_step_params: { application_merits_task_involved_child: { full_name: nil }, id: "new" })
          request
          expect(response).to redirect_to("/providers/applications/#{application.id}/involved_children/new?locale=en")
        end
      end

      context "when saved as draft and linking children" do
        it do
          lead_proceeding = application.proceedings.find_by(lead_proceeding: true)
          application.update!(provider_step: "linked_children", provider_step_params: { merits_task_list_id: lead_proceeding.id })
          request
          expect(response).to redirect_to("/providers/merits_task_list/#{lead_proceeding.id}/linked_children?locale=en")
        end
      end

      context "when saved as draft and returning to date_client_told_incident" do
        it do
          application.update!(provider_step: "date_client_told_incidents",
                              provider_step_params: { application_merits_task_incident: { told_on_3i: "",
                                                                                          told_on_2i: "",
                                                                                          told_on_1i: "",
                                                                                          occurred_on_3i: "",
                                                                                          occurred_on_2i: "",
                                                                                          occurred_on_1i: "" } })
          request
          expect(response).to redirect_to("/providers/applications/#{application.id}/date_client_told_incident?locale=en")
        end
      end

      context "when saved as draft and returning to chances_of_success" do
        it do
          lead_proceeding = application.proceedings.find_by(lead_proceeding: true)
          application.update!(provider_step: "chances_of_success", provider_step_params: { merits_task_list_id: lead_proceeding.id })
          request
          expect(response).to redirect_to("/providers/merits_task_list/#{lead_proceeding.id}/chances_of_success?locale=en")
        end
      end

      context "when removing a dependant" do
        let(:dependant) { create(:dependant, legal_aid_application: application) }

        it "routes correctly" do
          application.update!(provider_step: "remove_dependants", provider_step_params: { id: dependant.id })
          request
          expect(response).to redirect_to("/providers/applications/#{application.id}/means/remove_dependants/#{dependant.id}?locale=en")
        end
      end

      context "when legal_aid_application current path is unknown" do
        it "links to start of journey" do
          application.update!(provider_step: :unknown)
          request
          start_path = Flow::KeyPoint.path_for(
            journey: :providers,
            key_point: :edit_applicant,
            legal_aid_application: application,
          )
          expect(response).to redirect_to(start_path)
        end
      end

      context "when the application predates the 2023 surname at birth issue" do
        let(:application) do
          travel_to Date.parse("2023-12-25") do
            create(:application, :with_multiple_proceedings_inc_section8, provider_step:)
          end
        end

        context "and the provider step is not in the expired_by_2023_surname_at_birth_issue expiry exclusion list" do
          let(:provider_step) { "chances_of_success" }

          it "routes to the block page" do
            application_id = application.id
            request
            expect(response).to redirect_to("/providers/applications/#{application_id}/voided-application?locale=en")
          end
        end

        context "and the provider step is in the expired_by_2023_surname_at_birth_issue expiry exclusion list" do
          let(:provider_step) { "submitted_applications" }

          it "routes to the submitted application page" do
            application_id = application.id
            request
            expect(response).to redirect_to("/providers/applications/#{application_id}/submitted_application?locale=en")
          end
        end
      end
    end
  end
end
