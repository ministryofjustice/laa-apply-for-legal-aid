require "rails_helper"

RSpec.describe Providers::ClientCompletedMeansController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_transaction_period, applicant:, partner:) }
  let(:applicant) { create(:applicant, :employed, has_partner:) }
  let(:has_partner) { false }
  let(:partner) { nil }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:id/client_completed_means" do
    subject(:get_request) { get providers_legal_aid_application_client_completed_means_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Your client has shared their financial information")
      end

      context "when the applicant has no partner" do
        context "and the applicant is not employed" do
          let(:applicant) { create(:applicant, :not_employed) }

          it "does not include reviewing employment details in action list" do
            expect(response.body).to include("1. Tell us about their income and outgoings")
            expect(response.body).to include("2. Sort their bank transactions into categories")
            expect(response.body).to include("3. Tell us about their dependants")
            expect(response.body).to include("4. Tell us about their capital")
            expect(response.body).not_to include("Review their employment income")
          end

          it "includes income and outgoings as first point" do
            expect(response.body).to include("1. Tell us about their income and outgoings")
          end
        end

        context "and the applicant is employed" do
          it "includes reviewing employment details in action list" do
            expect(response.body).to include("1. Review their employment income")
            expect(response.body).to include("2. Tell us about their income and outgoings")
            expect(response.body).to include("3. Sort their bank transactions into categories")
            expect(response.body).to include("4. Tell us about their dependants")
            expect(response.body).to include("5. Tell us about their capital")
          end
        end
      end

      context "when the applicant has a partner" do
        let(:has_partner) { true }
        let(:partner) { create(:partner) }

        context "and the applicant is not employed" do
          let(:applicant) { create(:applicant, :not_employed, has_partner:) }

          it "the steps list only includes one option" do
            expect(response.body).to include("1. Tell us about their income and outgoings")
            expect(response.body).not_to include("Sort their bank transactions into categories")
            expect(response.body).not_to include("Tell us about their dependants")
            expect(response.body).not_to include("Tell us about their capital")
          end
        end

        context "when the applicant is employed" do
          it "the steps list only includes two options" do
            expect(response.body).to include("1. Review their employment income")
            expect(response.body).to include("2. Tell us about their income and outgoings")
            expect(response.body).not_to include("Sort their bank transactions into categories")
            expect(response.body).not_to include("Tell us about their dependants")
            expect(response.body).not_to include("Tell us about their capital")
          end
        end
      end
    end
  end

  describe "PATCH /providers/applications/:id/client_completed_means" do
    subject(:patch_request) { patch providers_legal_aid_application_client_completed_means_path(legal_aid_application), params: params.merge(submit_button) }

    let(:params) { {} }

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when the continue button is pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        context "and provider says applicant is employed" do
          before { applicant.update!(employed: true) }

          context "and HMRC is unavailable" do
            it { is_expected.to redirect_to(providers_legal_aid_application_means_hmrc_unavailable_interrupt_path(legal_aid_application)) }
          end

          context "and HMRC data is available" do
            before do
              create(:hmrc_response, :use_case_one, legal_aid_application:, owner: legal_aid_application.applicant)
            end

            context "but client has no national insurance number" do
              let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_no_nino, :with_transaction_period) }
              let(:applicant) { legal_aid_application.applicant }

              it { is_expected.to redirect_to(providers_legal_aid_application_means_no_nino_interrupt_path(legal_aid_application)) }
            end

            context "and no employment income data was received from HMRC" do
              it { is_expected.to redirect_to(providers_legal_aid_application_means_employed_but_no_hmrc_data_interrupt_path(legal_aid_application)) }
            end

            context "and employment income data for a single job was received from HMRC" do
              before { create(:employment, :with_payments_in_transaction_period, legal_aid_application:, owner_id: applicant.id, owner_type: applicant.class) }

              it { is_expected.to redirect_to(providers_legal_aid_application_means_single_employment_interrupt_path(legal_aid_application)) }
            end

            context "and employment income data for multiple jobs was received from HMRC" do
              before { create_list(:employment, 2, :with_payments_in_transaction_period, legal_aid_application:, owner_id: applicant.id, owner_type: applicant.class) }

              it { is_expected.to redirect_to(providers_legal_aid_application_means_multiple_employments_interrupt_path(legal_aid_application)) }
            end
          end
        end

        context "and provider says applicant is not employed" do
          before { applicant.update!(employed: false) }

          context "and HMRC is unavailable" do
            context "and the client is not uploading bank statements" do
              it { is_expected.to redirect_to(providers_legal_aid_application_means_identify_types_of_income_path(legal_aid_application)) }
            end

            context "and the client is uploading bank statements" do
              let(:legal_aid_application) do
                create(:legal_aid_application, :with_client_uploading_bank_statements, :with_transaction_period, applicant:, partner:)
              end

              it { is_expected.to redirect_to(providers_legal_aid_application_means_receives_state_benefits_path(legal_aid_application)) }
            end
          end

          context "and HMRC data is available" do
            before do
              create(:hmrc_response, :use_case_one, legal_aid_application:, owner: legal_aid_application.applicant)
            end

            context "but client has no national insurance number" do
              let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_no_nino, :with_transaction_period) }

              context "and the client is not uploading bank statements" do
                it { is_expected.to redirect_to(providers_legal_aid_application_means_identify_types_of_income_path(legal_aid_application)) }
              end

              context "and the client is uploading bank statements" do
                let(:legal_aid_application) do
                  create(:legal_aid_application, :with_client_uploading_bank_statements, :with_applicant_no_nino, :with_transaction_period, applicant:, partner:)
                end

                it { is_expected.to redirect_to(providers_legal_aid_application_means_receives_state_benefits_path(legal_aid_application)) }
              end
            end

            context "and no employment income data was received from HMRC" do
              context "and the client is not uploading bank statements" do
                it { is_expected.to redirect_to(providers_legal_aid_application_means_identify_types_of_income_path(legal_aid_application)) }
              end

              context "and the client is uploading bank statements" do
                let(:legal_aid_application) do
                  create(:legal_aid_application, :with_client_uploading_bank_statements, :with_transaction_period, applicant:, partner:)
                end

                it { is_expected.to redirect_to(providers_legal_aid_application_means_receives_state_benefits_path(legal_aid_application)) }
              end
            end

            context "and unexpected employment data was received from HMRC" do
              before { create(:employment, :with_payments_in_transaction_period, legal_aid_application:, owner_id: applicant.id, owner_type: applicant.class) }

              it { is_expected.to redirect_to(providers_legal_aid_application_means_unemployed_but_hmrc_found_data_interrupt_path(legal_aid_application)) }
            end
          end
        end

        context "and an unknown result was obtained from HMRC::StatusAnalyzer" do
          before do
            allow(HMRC::StatusAnalyzer).to receive(:call).with(legal_aid_application).and_return(:xxx)
          end

          it "raises an error" do
            expect { patch_request }.to raise_error RuntimeError, "Unexpected hmrc status :xxx"
          end
        end
      end

      context "when the Save as draft is button pressed" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          patch_request
          expect(response).to redirect_to(in_progress_providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          patch_request
          expect(legal_aid_application.reload).to be_draft
        end
      end
    end
  end
end
