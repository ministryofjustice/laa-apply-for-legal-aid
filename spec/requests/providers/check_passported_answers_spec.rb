require "rails_helper"

RSpec.describe "check passported answers requests" do
  include ActionView::Helpers::NumberHelper

  describe "GET /providers/applications/:id/check_passported_answers" do
    subject(:get_request) { get "/providers/applications/#{application.id}/check_passported_answers" }

    let(:vehicles) { create_list(:vehicle, 1, :populated) }
    let(:own_vehicle) { true }
    let!(:application) do
      create(:legal_aid_application,
             :with_everything,
             :with_proceedings,
             :with_passported_state_machine,
             :provider_entering_means,
             vehicles:,
             own_vehicle:)
    end

    context "when the provider is unauthenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when logged in as an authenticated provider" do
      before do
        login_as application.provider
        application.reload
        get_request
      end

      let(:vehicle) { application.vehicles.first }

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the correct details" do
        expect(response.body).to include(I18n.t("shared.forms.own_home_form.#{application.own_home}"))
        expect(response.body).to include(gds_number_to_currency(application.property_value, unit: "£"))
        expect(response.body).to include(gds_number_to_currency(application.outstanding_mortgage_amount, unit: "£"))
        expect(response.body).to include(I18n.t("shared.forms.shared_ownership_form.#{application.shared_ownership}"))
        expect(response.body).to include(number_to_percentage(application.percentage_home, precision: 2))
        expect(response.body).to include(I18n.t("shared.check_answers.assets.property.own_home"))
        expect(unescaped_response_body).to include(I18n.t("shared.check_answers.assets.property.property_value"))
        expect(unescaped_response_body).to include(I18n.t("shared.check_answers.assets.property.outstanding_mortgage"))
        expect(unescaped_response_body).to include(I18n.t("shared.check_answers.assets.property.shared_ownership"))
        expect(unescaped_response_body).to include(I18n.t("shared.check_answers.assets.property.percentage_home"))
        expect(response.body).to include("Savings")
        expect(response.body).to include("assets")
        expect(response.body).to include("restrictions")
      end

      it "displays the correct vehicles details" do
        expect(response.body).to include(gds_number_to_currency(vehicle.estimated_value, unit: "£"))
        expect(response.body).to include(gds_number_to_currency(vehicle.payment_remaining, unit: "£"))
        expect(response.body).to include(I18n.t("shared.check_answers.vehicles.providers.heading"))
        expect(response.body).to include(I18n.t("shared.check_answers.vehicles.providers.own", individual: "your client"))
        expect(response.body).to include(I18n.t("shared.check_answers.vehicles.providers.estimated_value"))
        expect(response.body).to include(I18n.t("shared.check_answers.vehicles.providers.payment_remaining"))
        expect(response.body).to include(I18n.t("shared.check_answers.vehicles.providers.more_than_three_years_old"))
        expect(response.body).to include(I18n.t("shared.check_answers.vehicles.providers.used_regularly"))
      end

      it "displays no categories selected in the policy disregards section" do
        parsed_response = Nokogiri::HTML(response.body)
        node = parsed_response.css("#app-check-your-answers__policy_disregards_header + .govuk-summary-list")
        expect(node.text).not_to include(I18n.t(".generic.yes"))
      end

      context "when the applicant does not have any savings" do
        let(:application) do
          create(:legal_aid_application,
                 :with_everything,
                 :with_proceedings,
                 :with_no_savings,
                 :with_passported_state_machine,
                 :provider_entering_means)
        end

        it "displays no categories selected in the savings and investments section" do
          parsed_response = Nokogiri::HTML(response.body)
          node = parsed_response.css("#app-check-your-answers__savings_and_investments_items")
          expect(node.text).not_to include(I18n.t(".generic.yes"))
        end
      end

      context "when the applicant does not have any other assets" do
        let(:application) do
          create(:legal_aid_application,
                 :with_everything,
                 :with_proceedings,
                 :with_no_other_assets,
                 :with_passported_state_machine,
                 :provider_entering_means)
        end

        it "displays that no other assets have been declared" do
          parsed_response = Nokogiri::HTML(response.body)
          node = parsed_response.css("#app-check-your-answers__other_assets_items")
          expect(node.text).not_to include(I18n.t(".generic.yes"))
        end
      end

      context "when the applicant does not have any capital restrictions" do
        let(:application) do
          create(:legal_aid_application,
                 :with_everything,
                 :with_proceedings,
                 :with_passported_state_machine,
                 :provider_entering_means,
                 has_restrictions: false)
        end

        it "displays that no capital restrictions have been declared" do
          parsed_response = Nokogiri::HTML(response.body)
          node = parsed_response.css("#app-check-your-answers__restrictions")
          expect(node.text).to include(I18n.t(".generic.no"))
        end
      end

      context "when the applicant does not have any capital" do
        let(:application) do
          create(:legal_aid_application,
                 :with_applicant,
                 :with_nil_savings_amount,
                 :with_proceedings,
                 :with_policy_disregards,
                 :without_own_home,
                 :with_passported_state_machine,
                 :provider_entering_means)
        end

        it "does not display capital restrictions" do
          expect(response.body).not_to include("restrictions")
        end
      end

      it "displays the correct URLs for changing values" do
        expect(response.body).to have_change_link(:own_home, providers_legal_aid_application_means_own_home_path(application))
        expect(response.body).to have_change_link(:property_value, providers_legal_aid_application_means_property_details_path(application))
        expect(response.body).to have_change_link(:shared_ownership, providers_legal_aid_application_means_property_details_path(application))
        expect(response.body).to have_change_link(:percentage_home, providers_legal_aid_application_means_property_details_path(application))
        expect(response.body).to include(providers_legal_aid_application_offline_account_path(application))
        expect(response.body).to include(providers_legal_aid_application_means_other_assets_path(application))
        expect(response.body).to include(providers_legal_aid_application_means_restrictions_path(application))
      end

      it "displays the correct savings details" do
        application.savings_amount.amount_attributes.each_value do |amount|
          expect(response.body).to include(gds_number_to_currency(amount, unit: "£")), "saving amount should be in the page"
        end
      end

      it "displays the correct assets details" do
        application.other_assets_declaration.amount_attributes.each do |attr, amount|
          expected = if attr == "second_home_percentage"
                       number_to_percentage(amount, precision: 2)
                     else
                       gds_number_to_currency(amount, unit: "£")
                     end
          expect(response.body).to include(expected), "asset amount should be in the page"
        end
      end

      it 'changes the state to "checking_passported_answers"' do
        expect(application.reload).to be_checking_passported_answers
      end

      context "when the applicant does not own home" do
        let(:application) do
          create(:legal_aid_application,
                 :with_everything,
                 :with_proceedings,
                 :without_own_home,
                 :with_passported_state_machine,
                 :provider_entering_means)
        end

        it "does not display property value" do
          expect(response.body).not_to include(gds_number_to_currency(application.property_value, unit: "£"))
          expect(response.body).not_to include("Property value")
        end

        it "does not display shared ownership question" do
          expect(response.body).not_to include(I18n.t("shared.forms.shared_ownership_form.#{application.shared_ownership}"))
          expect(response.body).not_to include("Owned with anyone else")
        end
      end

      context "when the applicant owns home without mortgage" do
        let(:application) do
          create(:legal_aid_application,
                 :with_everything,
                 :with_proceedings,
                 :with_own_home_owned_outright,
                 :with_passported_state_machine,
                 :provider_entering_means)
        end

        it "does not display property value" do
          expect(response.body).not_to include(gds_number_to_currency(application.outstanding_mortgage_amount, unit: "£"))
          expect(response.body).not_to include("Outstanding mortgage")
        end
      end

      context "when the applicant received england infected blood scheme payments" do
        before do
          create(:legal_aid_application,
                 :with_everything,
                 :with_proceedings,
                 :with_passported_state_machine,
                 :provider_entering_means,
                 :with_populated_policy_disregards,
                 vehicles:,
                 own_vehicle:)
        end

        it "displays yes for england infected scheme" do
          expect(response.body).to include("England Infected Blood Support Scheme")
        end
      end

      context "when the applicant does not have a vehicle" do
        let(:vehicles) { [] }
        let(:own_vehicle) { false }

        it "displays first vehicle question" do
          expect(response.body).to include(I18n.t("shared.check_answers.vehicles.providers.own", individual: "your client"))
        end

        it "does not display other vehicle questions" do
          expect(response.body).not_to include("What is the estimated value of the vehicle?")
          expect(response.body).not_to include("Are there any payments left on the vehicle?")
          expect(response.body).not_to include("The vehicle was bought more than three years ago?")
          expect(response.body).not_to include("Is the vehicle in regular use?")
        end
      end
    end
  end

  describe "PATCH /providers/applications/:id/check_passported_answers/continue" do
    subject(:patch_request) do
      patch(
        "/providers/applications/#{application.id}/check_passported_answers/continue",
        params:,
      )
    end

    let(:application) do
      create(:legal_aid_application,
             :with_everything,
             :with_passported_state_machine,
             :checking_passported_answers)
    end
    let(:params) { {} }

    context "when logged in as an authenticated provider" do
      before do
        login_as application.provider
      end

      context "when the call to Check Financial Eligibility Service is successful" do
        before do
          allow(CFECivil::SubmissionBuilder).to receive(:call).with(application).and_return(true)
          patch_request
        end

        it "redirects to next step" do
          expect(response).to have_http_status(:redirect)
        end

        it "transitions to provider_entering_merits state" do
          expect(application.reload.provider_entering_merits?).to be true
        end

        context "when the Form is submitted using Save as draft button" do
          let(:params) { { draft_button: "Save as draft" } }

          it "redirects provider to provider's applications page" do
            patch_request
            expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
          end

          it "sets the application as draft" do
            expect(application.reload).to be_draft
          end
        end
      end

      context "when the call to Check Financial Eligibility Service is unsuccessful" do
        before do
          allow(CFECivil::SubmissionBuilder).to receive(:call).with(application).and_return(false)
          patch_request
        end

        it "redirects to the problem page" do
          expect(response).to redirect_to(problem_index_path)
        end
      end
    end

    context "when the provider is unauthenticated" do
      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end
  end

  describe 'PATCH "/providers/applications/:id/check_passported_answers/reset' do
    subject(:patch_request) { patch "/providers/applications/#{application.id}/check_passported_answers/reset" }

    let(:application) do
      create(:legal_aid_application,
             :with_everything,
             :with_passported_state_machine,
             :checking_passported_answers,
             :with_proceedings)
    end

    context "when the provider is unauthenticated" do
      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when logged in as an authenticated provider" do
      let(:application) do
        create(:legal_aid_application,
               :with_everything,
               :with_proceedings,
               :with_passported_state_machine,
               :provider_entering_means)
      end

      before do
        login_as application.provider
        get providers_legal_aid_application_means_other_assets_path(application)
        get providers_legal_aid_application_check_passported_answers_path(application)
        patch_request
      end

      it "transitions to provider_assessing_merits state" do
        expect(application.reload.provider_entering_means?).to be true
      end

      it "redirects to the previous page" do
        expect(response).to redirect_to providers_legal_aid_application_means_other_assets_path(application, back: true)
      end
    end
  end
end
