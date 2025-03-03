require "rails_helper"

RSpec.describe Providers::ProceedingsSCA::InterruptsController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:current_proceeding) { create(:proceeding, :pb007) }
  let(:provider) { legal_aid_application.provider }
  let(:display) { "supervision" }

  before { legal_aid_application.proceedings << current_proceeding }

  describe "GET /providers/applications/:id/interrupt/:type" do
    subject(:get_request) { get providers_legal_aid_application_sca_interrupt_path(legal_aid_application, display) }

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
      end

      context "when passed a type of 'heard_as_alternatives'" do
        let(:display) { "heard_as_alternatives" }

        it "shows the expected interrupt content" do
          expect(page)
            .to have_content("You cannot submit this application under special children act")
            .and have_content("This is because it needs to be means and merits tested")
            .and have_content("check for a different matter type in this service or use CCMS")
            .and have_content("go back and change your answer")
            .and have_content("Check for another matter type")
        end
      end

      context "when passed a type of 'supervision'" do
        let(:display) { "supervision" }

        it "shows the expected interrupt content" do
          expect(page)
            .to have_content("For special children act, a supervision order cannot be varied, discharged or extended")
            .and have_content("select a different proceeding or matter type")
            .and have_content("go back and change your answer")
            .and have_content("Remove the proceeding and select a new one")
        end
      end

      context "when passed a type of 'child_subject'" do
        let(:display) { "child_subject" }

        it "shows the expected interrupt content" do
          expect(page)
            .to have_content("For special children act, your client must be the child subject of the proceeding")
            .and have_content("select a different proceeding or matter type")
            .and have_content("go back and change your answer")
            .and have_content("Remove the proceeding and select a new one")
        end
      end

      context "when passed a type of 'plf_none_selected'" do
        let(:display) { "plf_none_selected" }

        it "shows the expected interrupt content" do
          expect(page)
            .to have_content("This is not a public law family matter")
            .and have_content("This is because it does not relate to an application or order set out in schedule 1, part 1, paragraph 1 of LASPO.")
            .and have_content("select a different proceeding in this service or use CCMS")
            .and have_content("go back and change your answer")
            .and have_content("Select a different proceeding")
        end
      end

      context "when passed an unknown type" do
        let(:display) { "jedi" }

        it "shows default text and a button to select a different proceeding" do
          expect(response.body).to include("You cannot choose a special children act proceeding if it has not been issued")
          expect(response.body).to include("Remove the proceeding and select a new one")
        end
      end
    end
  end

  describe "DELETE /providers/applications/:id/interrupt/:current_proceeding/:type" do
    subject(:delete_request) { delete "/providers/applications/#{legal_aid_application.id}/interrupt/#{display}" }

    context "when the provider is not authenticated" do
      before { delete_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        delete_request
      end

      it "redirects to the proceeding types path" do
        expect(response).to redirect_to providers_legal_aid_application_proceedings_types_path
      end

      it "deletes the current proceeding" do
        expect { current_proceeding.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
