require "rails_helper"

RSpec.describe "Backable", vcr: { cassette_name: "backable", allow_playback_repeats: true } do
  let(:application) { create(:legal_aid_application, :with_applicant) }
  let(:address_lookup_path) { providers_legal_aid_application_correspondence_address_lookup_path(application) }
  let(:address_path) { providers_legal_aid_application_correspondence_address_manual_path(application) }
  let(:proceeding_type_path) { providers_legal_aid_application_proceedings_types_path(application) }
  let(:statement_of_case_upload_list_path) { list_providers_legal_aid_application_statement_of_case_upload_path(application) }
  let(:address_params) do
    {
      address:
      {
        address_line_one: "123",
        address_line_two: "High Street",
        city: "London",
        county: "Greater London",
        postcode: "SW1H 9AJ",
      },
    }
  end

  before { login_as application.provider }

  describe "#back_path" do
    context "when navigating through several pages" do
      before do
        get address_lookup_path
        get address_path
        patch address_path, params: address_params
        get proceeding_type_path
      end

      it "has a back link to the previous page" do
        expect(response.body).to have_back_link("#{address_path}&back=true")
      end

      context "when we reload the current page several times" do
        before do
          get proceeding_type_path
          get proceeding_type_path
        end

        it "has a back link to the previous page" do
          expect(response.body).to have_back_link("#{address_path}&back=true")
        end
      end

      context "when we go back once" do
        it "redirects to same page without the param" do
          get "#{address_path}&back=true"
          expect(response).to redirect_to(address_path)
        end

        it "has a link to the previous page" do
          get "#{address_path}&back=true"
          get address_path
          expect(response.body).to have_back_link("#{address_lookup_path}&back=true")
        end
      end

      context "when we have uploaded a statement of case in the merits task list" do
        before do
          get statement_of_case_upload_list_path
          get proceeding_type_path
        end

        it "does not link to the list_statement_of_case_upload_list_path" do
          expect(response.body).to have_back_link("#{address_path}&back=true")
        end
      end
    end

    # NOTE: recreation of real world incident where page history got corrupted by a user
    context "when the page history is corrupted" do
      before do
        get address_lookup_path
        get address_path

        # corrupt the last page history entry with invalid UTF-8 characters (an ellipse, "…")
        old_history = page_history_service.read
        corrupted_history = old_history.sub(/locale=en(?!.*locale=en)/, 'lo\xE2\x80\xA6')
        page_history_service.write(corrupted_history)
      end

      let(:page_history_service) { PageHistoryService.new(page_history_id: session[:page_history_id]) }

      it "does not raise an error" do
        expect { get proceeding_type_path }.not_to raise_error
      end

      it "logs the JSON parse error" do
        expect(Rails.logger).to receive(:error).with(/page_history JSON parse error: invalid escape character in string/).at_least(:once)

        get proceeding_type_path
      end

      it "removes the corrupted entry from the history and stores Back link to the last valid page" do
        expect { JSON.parse(page_history_service.read) }.to raise_error(JSON::ParserError)

        get proceeding_type_path

        page_history = JSON.parse(page_history_service.read)
        expect(page_history.size).to be(1)
        expect(page_history.last).to eq(proceeding_type_path)
      end

      it "renders but does not show a Back link, because history has been cleared" do
        get proceeding_type_path

        expect(response).to have_http_status(:ok)
        expect(response).to render_template("providers/proceedings_types/index")
        expect(response.body).not_to include("Back")
      end
    end
  end
end
