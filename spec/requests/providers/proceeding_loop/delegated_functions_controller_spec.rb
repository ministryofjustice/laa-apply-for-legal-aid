require "rails_helper"

RSpec.describe "DelegatedFunctionsController" do
  let(:application) { create(:legal_aid_application, :with_proceedings) }
  let(:application_id) { application.id }
  let(:proceeding) { application.proceedings.first }
  let(:proceeding_id) { proceeding.id }
  let(:provider) { application.provider }
  let(:skip_patch) { false }

  describe "GET /providers/applications/:legal_aid_application_id/delegated_functions/:proceeding_id" do
    subject(:get_df) { get "/providers/applications/#{application_id}/delegated_functions/#{proceeding_id}" }

    context "when the provider is not authenticated" do
      before { get_df }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_df
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      context "with a non-Special children act (non-SCA) proceeding" do
        it "displays expected header, question and [not] hint" do
          expect(response.body)
            .to include("Proceeding 1")
            .and include("Inherent jurisdiction high court injunction")
            .and include("Have you used delegated functions for this proceeding?")

          expect(response.body).not_to include("Answer this, even for special children act")
        end
      end

      context "with an Special children act (SCA) proceeding" do
        let(:application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[pb003], set_lead_proceeding: :pb003) }

        it "displays expected header, question and SCA hint" do
          expect(response.body)
            .to include("Proceeding 1")
            .and include("Child assessment order")
            .and include("Have you used delegated functions for this proceeding?")
            .and include("Answer this, even for special children act")
        end
      end
    end
  end

  describe "POST /providers/applications/:legal_aid_application_id/delegated_functions/:proceeding_id" do
    subject(:post_df) { patch "/providers/applications/#{application_id}/delegated_functions/#{proceeding_id}", params: }

    before { allow(DelegatedFunctionsDateService).to receive(:call).and_return(true) }

    let(:params) do
      {
        proceeding: {
          used_delegated_functions: false,
        },
      }
    end

    context "when the provider is not authenticated" do
      before { post_df }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        post_df unless skip_patch
      end

      context "when the Continue button is pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        context "and the proceeding has used delegated functions" do
          let(:params) do
            {
              proceeding: {
                used_delegated_functions: true,
                used_delegated_functions_on: 5.days.ago.to_date.to_s(:date_picker),
              },
            }
          end

          it "redirects to next page" do
            expect(response.body).to redirect_to(providers_legal_aid_application_emergency_default_path(application_id, proceeding_id))
          end
        end

        context "and the proceeding has not used delegated functions" do
          it "redirects to next page" do
            expect(response.body).to redirect_to(providers_legal_aid_application_substantive_default_path(application_id, proceeding_id))
          end
        end

        context "and the date is more than a month old" do
          let(:params) do
            {
              proceeding: {
                used_delegated_functions: true,
                used_delegated_functions_on: 35.days.ago.to_date.to_s(:date_picker),
              },
            }
          end

          it "redirects to the confirmation page" do
            expect(response.body).to redirect_to(providers_legal_aid_application_confirm_delegated_functions_date_path(application_id, proceeding_id))
          end

          context "when provider changes yes to no" do
            before do
              proceeding.update!(
                used_delegated_functions: true,
                used_delegated_functions_on: 1.day.ago.to_date,
                used_delegated_functions_reported_on: Date.current,
              )
            end

            let(:skip_patch) { true }

            let(:params) do
              {
                proceeding: {
                  used_delegated_functions: false,
                },
              }
            end

            it "updates the proceeding to remove the previous values" do
              expect { post_df }
                .to change { proceeding.reload.attributes.symbolize_keys }
                  .from(
                    hash_including(
                      {
                        used_delegated_functions: true,
                        used_delegated_functions_on: 1.day.ago.to_date,
                        used_delegated_functions_reported_on: Date.current,
                      },
                    ),
                  ).to(
                    hash_including(
                      {
                        used_delegated_functions: false,
                        used_delegated_functions_on: nil,
                        used_delegated_functions_reported_on: nil,
                      },
                    ),
                  )
            end
          end
        end

        context "when checking answers" do
          let(:application) do
            create(
              :legal_aid_application,
              :with_applicant_and_address_lookup,
              :checking_applicant_details,
              :with_proceedings,
              :with_delegated_functions_on_proceedings,
              explicit_proceedings: %i[da001 se013],
              df_options: { DA001: [10.days.ago, 10.days.ago], SE013: nil },
              substantive_application_deadline_on: 10.days.from_now,
            ).reload
          end

          context "when pre-existing data is present" do
            let(:skip_patch) { true }

            before do
              proceeding.update!(accepted_emergency_defaults: true, accepted_substantive_defaults: false)
              post_df
            end

            it "resets the data" do
              expect(application.reload).to have_attributes(
                emergency_cost_requested: nil,
                emergency_cost_reasons: nil,
                substantive_cost_requested: nil,
                substantive_cost_reasons: nil,
              )
              expect(proceeding.reload).to have_attributes(
                accepted_emergency_defaults: nil,
                accepted_substantive_defaults: nil,
              )
            end
          end

          context "when the date is within the last month" do
            it "continues through the sub flow" do
              expect(response).to redirect_to(providers_legal_aid_application_substantive_default_path(application_id))
            end
          end

          context "when the date is more than a month old" do
            let(:params) do
              {
                proceeding: {
                  used_delegated_functions: true,
                  used_delegated_functions_on: 35.days.ago.to_date.to_s(:date_picker),
                },
              }
            end

            it "redirects to confirm delegated functions date page" do
              expect(response).to redirect_to(providers_legal_aid_application_confirm_delegated_functions_date_path(application_id, proceeding_id))
            end
          end

          context "and the proceeding has used delegated functions" do
            let(:params) do
              {
                proceeding: {
                  used_delegated_functions: true,
                  used_delegated_functions_on: 5.days.ago.to_date.to_s(:date_picker),
                },
              }
            end

            it "redirects to next page" do
              expect(response.body).to redirect_to(providers_legal_aid_application_emergency_default_path(application_id, proceeding_id))
            end
          end

          context "and the proceeding has not used delegated functions" do
            it "redirects to next page" do
              expect(response.body).to redirect_to(providers_legal_aid_application_substantive_default_path(application_id, proceeding_id))
            end
          end
        end
      end
    end
  end
end
