require "rails_helper"

RSpec.describe PagesController, :clamav do
  context "when not in maintenance mode" do
    context "when provider signs in" do
      before do
        sign_in provider
        get root_path
      end

      let(:provider) { create(:provider) }

      it "renders root page as expected" do
        expect(response).to render_template("providers/start/index")
      end
    end
  end

  context "when in maintenance mode" do
    before do
      allow(Rails.application.config.x).to receive(:maintenance_mode).and_return(true)
      Rails.application.reload_routes!
    end

    after do
      allow(Rails.application.config.x).to receive(:maintenance_mode).and_return(false)
      Rails.application.reload_routes!
    end

    shared_examples "maintenance page" do
      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to render_template("pages/servicedown") }
      it { expect(response.body).to include("Sorry, the service is unavailable") }
    end

    shared_examples "maintenance json" do
      it { expect(response).to have_http_status :service_unavailable }
      it { expect(response.body).to include({ error: "Service temporarily unavailable" }.to_json) }
    end

    context "when provider signs in" do
      before do
        sign_in provider
        get root_path
      end

      let(:provider) { create(:provider) }

      it_behaves_like "maintenance page"
    end

    context "when different formats requested" do
      context "with html" do
        before { get "/", params: { format: :html } }

        it_behaves_like "maintenance page"
      end

      context "with json" do
        before { get "/", params: { format: :json } }

        it_behaves_like "maintenance json"
      end

      context "with ajax" do
        before { get "/", xhr: true, params: { format: :js } }

        it_behaves_like "maintenance json"
      end

      context "when other format" do
        before { get "/", params: { format: :axd } }

        it { expect(response).to have_http_status :service_unavailable }
        it { expect(response.body).to include("Service temporarily unavailable") }
      end
    end
  end

  describe "out of hours access" do
    let(:citizen_access_token) do
      create(
        :citizen_access_token,
        legal_aid_application: create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :awaiting_applicant),
      )
    end
    let(:token) { citizen_access_token.token }
    let(:citizen_access_request) { get citizens_legal_aid_application_path(token) }
    let(:landing_page_request) { get root_path }

    around do |example|
      travel_to(new_time) { example.run }
    end

    context "when it's British Summer Time" do
      context "when it's 0500 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 9, 8, 5, 0, 0) }

        it "allows citizen traffic" do
          citizen_access_request
          expect(response).to redirect_to(citizens_legal_aid_applications_path)
        end

        it "blocks provider traffic" do
          landing_page_request
          expect(response).to render_template("pages/service_out_of_hours")
        end
      end

      context "when it's 0700 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 9, 8, 7, 0, 0) }

        it "allows citizen traffic" do
          citizen_access_request
          expect(response).to redirect_to(citizens_legal_aid_applications_path)
        end

        it "allows provider traffic" do
          landing_page_request
          expect(response).to render_template("providers/start/index")
        end
      end

      context "when it's 0900 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 9, 8, 9, 0, 0) }

        it "allows citizen traffic" do
          citizen_access_request
          expect(response).to redirect_to(citizens_legal_aid_applications_path)
        end

        it "allows provider traffic" do
          landing_page_request
          expect(response).to render_template("providers/start/index")
        end
      end

      context "when it's 1859 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 9, 8, 18, 59, 0) }

        it "allows citizen traffic" do
          citizen_access_request
          expect(response).to redirect_to(citizens_legal_aid_applications_path)
        end

        it "allows provider traffic" do
          landing_page_request
          expect(response).to render_template("providers/start/index")
        end
      end

      context "when it's 1900 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 9, 8, 19, 0, 0) }

        it "allows citizen traffic" do
          citizen_access_request
          expect(response).to redirect_to(citizens_legal_aid_applications_path)
        end

        it "blocks provider traffic" do
          landing_page_request
          expect(response).to render_template("pages/service_out_of_hours")
        end
      end

      context "when it's 1300 on a Sunday" do
        let(:new_time) { Time.zone.local(2025, 9, 7, 13, 0, 0) }

        it "allows citizen traffic" do
          citizen_access_request
          expect(response).to redirect_to(citizens_legal_aid_applications_path)
        end

        it "blocks provider traffic" do
          landing_page_request
          expect(response).to render_template("pages/service_out_of_hours")
        end
      end
    end

    context "when it's GMT" do
      context "when it's 0630 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 11, 3, 6, 30, 0) }

        it "blocks provider traffic" do
          landing_page_request
          expect(response).to render_template("pages/service_out_of_hours")
        end
      end

      context "when it's 0730 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 11, 3, 7, 30, 0) }

        it "allows provider traffic" do
          landing_page_request
          expect(response).to render_template("providers/start/index")
        end
      end

      context "when it's 1830 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 11, 3, 18, 30, 0) }

        it "allows provider traffic" do
          landing_page_request
          expect(response).to render_template("providers/start/index")
        end
      end

      context "when it's 1930 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 11, 3, 19, 30, 0) }

        it "blocks provider traffic" do
          landing_page_request
          expect(response).to render_template("pages/service_out_of_hours")
        end
      end
    end
  end
end
