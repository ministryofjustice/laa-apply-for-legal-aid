require "rails_helper"

RSpec.describe Providers::Means::RemoveDependantsController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:dependant) { create(:dependant, legal_aid_application:) }
  let(:login) { login_as legal_aid_application.provider }
  let(:extra_dependant_count) { 0 }

  before do
    create_list(:dependant, extra_dependant_count, legal_aid_application:)
    login
    subject
  end

  describe "GET /providers/:application_id/means/remove_dependants/:dependant_id" do
    subject { get providers_legal_aid_application_means_remove_dependant_path(legal_aid_application, dependant) }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end
  end

  describe "PATCH /providers/:application_id/means/remove_dependants/:dependant_id" do
    subject { patch providers_legal_aid_application_means_remove_dependant_path(legal_aid_application, dependant), params: }

    let(:params) do
      {
        binary_choice_form: {
          remove_dependant:,
        },
      }
    end

    context "choose yes" do
      let(:remove_dependant) { "true" }

      context "when no dependants remain after deletion" do
        it "redirects to the has_dependants page" do
          expect(response).to redirect_to(providers_legal_aid_application_means_has_dependants_path(legal_aid_application))
        end

        it { expect(legal_aid_application.dependants.count).to eq 0 }

        it "resets the has_dependants value" do
          # this prevents the 'yes' checkbox being selected when the provider returns to the page
          expect(legal_aid_application.has_dependants?).to be false
        end
      end

      context "when dependants remain after the deletion" do
        let(:extra_dependant_count) { 1 }

        it "redirects to the has_other_dependants page" do
          expect(response).to redirect_to(providers_legal_aid_application_means_has_other_dependants_path(legal_aid_application))
        end
      end
    end

    context "choose no" do
      let(:remove_dependant) { "false" }

      it "redirects to the has other dependants page" do
        expect(response).to redirect_to(providers_legal_aid_application_means_has_other_dependants_path(legal_aid_application))
      end
    end

    context "try a hack to submit something else" do
      let(:remove_dependant) { "not sure" }

      it "show errors" do
        expect(response.body).to include(I18n.t("providers.means.remove_dependants.show.error", name: dependant.name))
      end
    end

    context "choose nothing" do
      let(:params) { nil }

      it "show errors" do
        expect(response.body).to include(I18n.t("providers.means.remove_dependants.show.error", name: dependant.name))
      end
    end
  end
end
