require "rails_helper"

RSpec.describe Providers::ApplicantsController do
  let(:office) { create(:office) }
  let(:provider) { create(:provider, selected_office: office) }
  let(:login) { login_as provider }

  before { login }

  describe "GET /providers/applicants/new" do
    subject(:request) { get new_providers_applicant_path }

    it "renders successfully" do
      request
      expect(response).to have_http_status(:ok)
    end

    it "does not prefix page title with error label" do
      request
      expect(response.body).not_to match(/<title>#{I18n.t('errors.title_prefix')}:/)
    end
  end

  describe "POST /providers/applicants" do
    subject(:request) { post providers_applicants_path, params: params.merge(submit_button) }

    let(:submit_button) { {} }

    let(:params) do
      {
        applicant: {
          first_name: "John",
          last_name: "Doe",
          "date_of_birth(1i)": "1981",
          "date_of_birth(2i)": "07",
          "date_of_birth(3i)": "11",
          changed_last_name: false,
        },
      }
    end

    let(:legal_aid_application) { provider.legal_aid_applications.last }
    let(:applicant) { legal_aid_application.applicant }

    it "creates an application with the provider's office" do
      expect { request }.to change { provider.legal_aid_applications.count }.by(1)
      expect(legal_aid_application.office.id).to eq(provider.selected_office.id)
    end

    it "creates an applicant" do
      expect { request }.to change(Applicant, :count).by(1)

      expect(applicant).to have_attributes(
        first_name: "John",
        last_name: "Doe",
        date_of_birth: Date.new(1981, 7, 11),
        national_insurance_number: nil,
        email: nil,
      )
    end

    it "redirects to the next page" do
      request
      expect(response).to have_http_status(:redirect)
    end

    it "back link on the next page is to applicant's details page" do
      get new_providers_applicant_path
      request
      follow_redirect!
      expect(response.body).to have_back_link(providers_legal_aid_application_applicant_details_path(legal_aid_application, back: true))
    end

    context "with missing parameters" do
      let(:params) { { applicant: { first_name: "bob" } } }

      it "displays errors" do
        request
        expect(response.body).to include("govuk-error-summary")
      end

      it "prefixes page title with error label" do
        request
        expect(response.body).to match(/<title>#{I18n.t('errors.title_prefix')}:/)
      end

      it "does not create applicant" do
        expect { request }.not_to change(Applicant, :count)
      end

      it "does not create application" do
        expect { request }.not_to change(LegalAidApplication, :count)
      end
    end

    context "with form submitted using Save as draft button" do
      let(:submit_button) { { draft_button: "Save as draft" } }

      it "redirects provider to provider's applications page" do
        request
        expect(response).to redirect_to(in_progress_providers_legal_aid_applications_path)
      end

      it "creates an application as draft" do
        expect { request }.to change { provider.legal_aid_applications.count }.by(1)
        expect(legal_aid_application.draft?).to be(true)
      end

      it "creates an applicant" do
        expect { request }.to change(Applicant, :count).by(1)

        expect(applicant).to have_attributes(
          first_name: "John",
          last_name: "Doe",
          date_of_birth: Date.new(1981, 7, 11),
          national_insurance_number: nil,
          email: nil,
        )
      end

      context "with blank entries" do
        let(:params) { { applicant: { first_name: "bob" } } }

        it "redirects provider to provider's applications page" do
          request
          expect(response).to redirect_to(in_progress_providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          request
          expect(legal_aid_application.draft?).to be(true)
        end

        it "leaves values blank" do
          request
          expect(applicant.last_name).to be_blank
          expect(applicant.national_insurance_number).to be_blank
        end
      end
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      before { request }

      it_behaves_like "a provider not authenticated"
    end
  end
end
