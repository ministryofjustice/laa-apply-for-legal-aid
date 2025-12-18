require "rails_helper"

RSpec.describe "providers legal aid application requests" do
  describe "GET /providers/applications/in_progress" do
    subject(:get_request) { get in_progress_providers_legal_aid_applications_path(params) }

    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, provider_step: :proceedings_types) }
    let(:provider) { legal_aid_application.provider }
    let(:other_provider) { create(:provider) }
    let(:other_provider_in_same_firm) { create(:provider, firm: provider.firm) }
    let(:params) { {} }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      it "returns http success" do
        get_request
        expect(response).to have_http_status(:ok)
      end

      it "includes a link to the legal aid application's resume path" do
        get_request
        expect(response.body).to include(providers_legal_aid_application_resume_path(legal_aid_application))
      end

      it "includes a link to the search page" do
        get_request
        expect(response.body).to include(search_providers_legal_aid_applications_path)
      end

      context "when legal_aid_application current path set" do
        let!(:other_provider_in_same_firm) { create(:provider, firm: provider.firm) }
        let!(:legal_aid_application) { create(:legal_aid_application, :with_applicant, provider_step: :applicant_details) }
        let!(:other_provider_in_same_firm_application) { create(:legal_aid_application, :with_applicant, provider: other_provider_in_same_firm, provider_step: :applicant_details) }
        let!(:other_provider_application) { create(:legal_aid_application, :with_applicant, provider: other_provider, provider_step: :applicant_details) }

        it "includes a link to the legal aid application's resume path" do
          get_request
          expect(response.body).to include(providers_legal_aid_application_resume_path(legal_aid_application))
        end

        it "includes a link to the application of the other provider in the same firm" do
          get_request
          expect(response.body).to include(providers_legal_aid_application_resume_path(other_provider_in_same_firm_application))
        end

        it "does not include a link to the application of the provider in a different firm" do
          get_request
          expect(response.body).not_to include(providers_legal_aid_application_applicant_details_path(other_provider_application))
        end
      end

      context "when legal_aid_application current path is unknown" do
        let!(:legal_aid_application) { create(:legal_aid_application, :with_applicant, provider_step: :unknown) }

        it "links to the resume page" do
          get_request
          expect(response.body).to include(providers_legal_aid_application_resume_path(legal_aid_application))
        end
      end

      context "with pagination" do
        it "shows current total information" do
          get_request
          expect(page).to have_css(".app-pagination__info", text: "Showing 1 of 1")
        end

        it "does not show navigation links" do
          get_request
          expect(page).to have_no_css(".govuk-pagination")
        end

        context "and more applications than page size" do
          # Creating 4 additional means there are now 5 applications
          before { create_list(:legal_aid_application, 4, :with_applicant, provider:, provider_step: :proceedings_types) }

          let(:params) { { page_size: 3 } }

          it "show page information" do
            get_request
            expect(page).to have_css(".app-pagination__info", text: "Showing 1 to 3 of 5 results")
          end

          it "shows pagination" do
            get_request
            expect(page)
              .to have_css(".govuk-pagination", text: "Next page")
              .and have_css(".govuk-pagination__link", text: "1")
              .and have_css(".govuk-pagination__link", text: "2")
          end
        end

        context "and navigating to a page that doesn't exist" do
          let(:params) { { page: 12 } }

          it "successfully redirects to page that exists" do
            get_request
            expect(response).to have_http_status(:ok)
          end
        end

        context "when an application has been discarded" do
          before { create(:legal_aid_application, :discarded, provider:) }

          it "is excluded from the list" do
            get_request
            expect(page).to have_css(".app-pagination__info", text: "Showing 1 of 1")
          end
        end
      end

      context "when provider's cookie preferences have expired" do
        let(:provider) { create(:provider, cookies_enabled: true, cookies_saved_at: 1.year.ago - 1.day) }

        it "displays the cookie banner" do
          get_request
          expect(response.body).to include("Cookies on Apply for civil legal aid")
        end
      end

      context "when provider's cookie preferences have not expired" do
        let(:provider) { create(:provider, cookies_enabled: true, cookies_saved_at: 1.year.ago + 1.day) }

        it "does not display the cookie banner" do
          get_request
          expect(response.body).not_to include("Cookies on Apply for civil legal aid")
        end
      end

      context "when the provider has not chosen their cookie preferences" do
        let(:provider) { create(:provider, cookies_enabled: nil, cookies_saved_at: nil) }

        it "displays the cookie banner" do
          get_request
          expect(response.body).to include("Cookies on Apply for civil legal aid")
        end
      end
    end

    context "when another provider is authenticated" do
      before do
        login_as other_provider
        get_request
      end

      it "displays no results" do
        expect(response.body).to include("You have <strong>0</strong> applications")
      end
    end
  end

  describe "GET /providers/applications/search" do
    subject(:get_request) { get search_providers_legal_aid_applications_path(params) }

    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
    let(:provider) { legal_aid_application.provider }
    let(:other_provider) { create(:provider) }
    let(:other_provider_in_same_firm) { create(:provider, firm: provider.firm) }
    let(:params) { {} }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      it "does not show any application" do
        get_request
        expect(response.body).not_to include(legal_aid_application.application_ref)
      end

      context "when searching for a Substantive application" do
        let(:search_term) { legal_aid_application.application_ref }
        let(:params) { { search_term: } }

        it "shows the application" do
          get_request
          expect(unescaped_response_body).to include(legal_aid_application.applicant.last_name)
          expect(unescaped_response_body).to include("Substantive")
        end

        it "logs the search" do
          expected_log = "Applications search: Provider #{provider.id} searched '#{search_term}' : 1 results."
          allow(Rails.logger).to receive(:info).at_least(:once)
          get_request
          expect(Rails.logger).to have_received(:info).with(expected_log).once
        end
      end

      context "when searching for an incomplete Emergency application with a substantive due date" do
        let(:legal_aid_application) do
          create(:legal_aid_application,
                 :with_applicant,
                 :with_proceedings,
                 :with_delegated_functions_on_proceedings,
                 explicit_proceedings: [:da004],
                 df_options: { DA004: [Time.zone.today, Time.zone.today] },
                 substantive_application_deadline_on: Time.zone.today + 3.days)
        end
        let(:search_term) { legal_aid_application.application_ref }
        let(:params) { { search_term: } }

        it "shows the application" do
          get_request
          expect(unescaped_response_body).to include("Emergency")
          expect(unescaped_response_body).to match(/Substantive due: \d{1,2} [ADFJMNOS]\w* \d{4}/)
          expect(legal_aid_application.summary_state).to eq(:in_progress)
        end
      end

      context "when searching for an Emergency application with a substantive due date and the application has been submitted" do
        let(:legal_aid_application) do
          create(:legal_aid_application,
                 :with_applicant,
                 :with_everything,
                 :with_proceedings,
                 :with_delegated_functions_on_proceedings,
                 explicit_proceedings: [:da004],
                 df_options: { DA004: [Time.zone.today, Time.zone.today] },
                 substantive_application_deadline_on: Time.zone.today + 3.days,
                 merits_submitted_at: Time.zone.today)
        end
        let(:search_term) { legal_aid_application.application_ref }
        let(:params) { { search_term: } }

        it "shows the application" do
          get_request
          expect(unescaped_response_body).to include("Emergency")
          expect(legal_aid_application.substantive_application_deadline_on).not_to be_nil
          expect(unescaped_response_body).not_to match(/Substantive due: \d{1,2} [ADFJMNOS]\w* \d{4}/)
          expect(legal_aid_application.summary_state).to eq(:submitted)
        end
      end

      context "when searching for the application and not result is found" do
        let(:params) { { search_term: "something" } }

        it "does not show the application" do
          get_request
          expect(unescaped_response_body).not_to include(legal_aid_application.application_ref)
        end
      end

      context "when not entering search criteria" do
        let(:params) { { search_term: "" } }

        it "shows an error" do
          get_request
          expect(response.body).to include(I18n.t("providers.legal_aid_applications.search.error"))
        end
      end
    end

    context "when another provider is authenticated and search the application" do
      let(:params) { { search_term: legal_aid_application.application_ref } }

      before do
        login_as other_provider
        get_request
      end

      it "does not show the application" do
        expect(unescaped_response_body).not_to include(legal_aid_application.applicant.last_name)
      end
    end
  end

  describe "POST /providers/applications" do
    subject(:post_request) { post providers_legal_aid_applications_path }

    let(:legal_aid_application) { LegalAidApplication.last }

    context "when the provider is authenticated" do
      before do
        login_as create(:provider)
      end

      it "does not create a new application record" do
        expect { post_request }.not_to change(LegalAidApplication, :count)
      end

      it "redirects to new applicant page" do
        post_request
        expect(response).to redirect_to(new_providers_applicant_path)
      end
    end
  end
end
