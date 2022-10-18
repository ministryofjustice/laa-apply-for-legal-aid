require "rails_helper"

RSpec.describe Providers::LimitationsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_proceedings, set_lead_proceeding: :da001 }
  let(:provider) { legal_aid_application.provider }

  before do
    legal_aid_application.reload
  end

  describe "GET /providers/applications/:id/limitations" do
    subject { get providers_legal_aid_application_limitations_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { subject }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        subject
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
        expect(unescaped_response_body).to include(I18n.t("providers.limitations.proceeding_types.h1-heading"))
      end

      it "puts scope limitations in a details section" do
        expect(parsed_response_body.css("details").text).to include(I18n.t("providers.limitations.proceeding_types.substantive_certificate"))
        expect(unescaped_response_body).not_to include(I18n.t("providers.limitations.proceeding_types_with_df.cost_override_question"))
      end

      context "when delegated functions have been used" do
        let(:legal_aid_application) { create :legal_aid_application, :with_proceedings, explicit_proceedings: [:da004], set_lead_proceeding: :da004 }
        let(:provider) { legal_aid_application.provider }

        it "shows the correct text" do
          expect(unescaped_response_body).to include(I18n.t("providers.limitations.proceeding_types_with_df.cost_override_question"))
        end
      end
    end

    describe "#pre_dwp_check?" do
      it "returns true" do
        expect(described_class.new.pre_dwp_check?).to be true
      end
    end
  end

  describe "PATCH /providers/applications/:id/limitations" do
    before do
      login_as provider
    end

    context "when delegated functions have not been used" do
      context "and the maximum substantive cost limit is at the threshold" do
        subject { patch providers_legal_aid_application_limitations_path(legal_aid_application) }

        let(:legal_aid_application) { create :legal_aid_application, :with_proceedings }

        it "redirects to next page" do
          expect(subject).to redirect_to(providers_legal_aid_application_check_provider_answers_path(legal_aid_application))
        end
      end

      context "and the maximum substantive cost limit is below the threshold" do
        subject { patch providers_legal_aid_application_limitations_path(legal_aid_application, params:) }

        let(:legal_aid_application) { create :legal_aid_application }

        before do
          create :proceeding, :da006, legal_aid_application:, substantive_cost_limitation: 5_000, lead_proceeding: true, used_delegated_functions_on: nil
          create :proceeding, :se013, legal_aid_application:, substantive_cost_limitation: 8_000, used_delegated_functions_on: nil
        end

        context "when no substantive limit extension is requested" do
          let(:params) do
            { legal_aid_application: { substantive_cost_override: false,
                                       substantive_cost_requested: nil,
                                       substantive_cost_reasons: nil } }
          end

          it "redirects to next page" do
            expect(subject).to redirect_to(providers_legal_aid_application_check_provider_answers_path(legal_aid_application))
          end
        end

        context "with the incorrect params" do
          let(:params) do
            { legal_aid_application: { substantive_cost_override: true,
                                       substantive_cost_requested: "non numeric response",
                                       substantive_cost_reasons: "this is just a test" } }
          end

          it "displays an error" do
            subject
            expect(response.body).to match("govuk-error-summary")
            expect(response.body).to include("Substantive cost limit must be an amount of money, like 2,500")
          end
        end
      end
    end

    context "when delegated functions have been used" do
      subject { patch providers_legal_aid_application_limitations_path(legal_aid_application, params:) }

      let(:legal_aid_application) { create :legal_aid_application, :with_proceedings, explicit_proceedings: [:da004], set_lead_proceeding: :da004 }
      let(:proceeding_type) { legal_aid_application.proceeding_types.first }
      let(:provider) { legal_aid_application.provider }

      context "with the correct params" do
        context "when no limit extensions are requested" do
          let(:params) do
            { legal_aid_application: { emergency_cost_override: false, substantive_cost_override: false } }
          end

          it "redirects to next page" do
            expect(subject).to redirect_to(providers_legal_aid_application_check_provider_answers_path(legal_aid_application))
          end
        end

        context "when a limit extension is requested" do
          let(:params) do
            { legal_aid_application: { emergency_cost_override: true,
                                       emergency_cost_requested: 3_000.0,
                                       emergency_cost_reasons: "this is just a test",
                                       substantive_cost_override: false,
                                       substantive_cost_requested: nil,
                                       substantive_cost_reasons: nil } }
          end

          it "redirects to next page" do
            expect(subject).to redirect_to(providers_legal_aid_application_check_provider_answers_path(legal_aid_application))
          end
        end
      end

      context "with the incorrect params" do
        let(:params) do
          { legal_aid_application: { emergency_cost_override: true,
                                     emergency_cost_requested: "non numeric response",
                                     emergency_cost_reasons: "this is just a test",
                                     substantive_cost_override: false,
                                     substantive_cost_requested: nil,
                                     substantive_cost_reasons: nil } }
        end

        it "displays an error" do
          subject
          expect(response.body).to match("govuk-error-summary")
          expect(response.body).to include("Emergency cost limit must be an amount of money, like 2,500")
        end
      end
    end
  end
end
