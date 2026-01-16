require "rails_helper"

RSpec.describe PagesController, :clamav do
  context "with invalid locale" do
    before do
      allow(Rails.logger).to receive(:warn)
      get unauthenticated_root_path, params: { locale: "enMobile" }
    end

    it "responds with success" do
      expect(response).to have_http_status(:ok)
    end

    it "renders page in default locale langauge, english" do
      expect(response).to render_template("providers/start/index")
      expect(response.body).to include("Sign in")
    end

    it "logs the invalid locale request" do
      expect(Rails.logger).to have_received(:warn).with(/Invalid locale requested: "enMobile".*\. Falling back to default locale./)
    end
  end

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
      allow(Rails.configuration.x).to receive(:laa_landing_page_target_url).and_return("https://my-made-up-single-sign-on-page")
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

      it "has expected content" do
        expect(page)
          .to have_content("Sorry, there is a problem")
          .and have_link("Online Support (opens in new tab)", href: "https://legalaidlearning.justice.gov.uk/online-support-2/")
      end
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

    before do
      allow(Rails.configuration.x.business_hours).to receive_messages(start: "7:00", end: "21:30")
    end

    around do |example|
      travel_to(new_time) { example.run }
    end

    after do
      allow(Rails.configuration.x.business_hours).to receive(:start).and_call_original
      allow(Rails.configuration.x.business_hours).to receive(:end).and_call_original
    end

    shared_examples "out of hours access" do
      it "allows citizen traffic" do
        citizen_access_request
        expect(response).to redirect_to(citizens_legal_aid_applications_path)
      end

      it "blocks provider traffic" do
        landing_page_request
        expect(response).to render_template("pages/service_out_of_hours")
        expect(response.body).not_to include("Sign in") # sign in link removed
        expect(response.body).not_to include("help us to improve it") # phase banner feedback link removed
      end

      it "displays expected content" do
        landing_page_request
        expect(response.body).to include("This service is available daily from 7am to 9:30pm. It is not available on bank holidays.")
      end
    end

    shared_examples "in hours access" do
      it "allows citizen traffic" do
        citizen_access_request
        expect(response).to redirect_to(citizens_legal_aid_applications_path)
      end

      it "allows provider traffic" do
        landing_page_request
        expect(response).to render_template("providers/start/index")
      end
    end

    context "when it's British Summer Time" do
      context "when it's 0500 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 9, 8, 5, 0, 0) }

        it_behaves_like "out of hours access"
      end

      context "when it's 0700 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 9, 8, 7, 0, 0) }

        it_behaves_like "in hours access"
      end

      context "when it's 0900 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 9, 8, 9, 0, 0) }

        it_behaves_like "in hours access"
      end

      context "when it's 2129 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 9, 8, 21, 29, 0) }

        it_behaves_like "in hours access"
      end

      context "when it's 2130 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 9, 8, 21, 30, 0) }

        it_behaves_like "out of hours access"
      end

      context "when it's 1300 on a Sunday" do
        let(:new_time) { Time.zone.local(2025, 9, 7, 13, 0, 0) }

        it_behaves_like "in hours access"
      end
    end

    context "when it's a bank holiday" do
      let(:bank_holidays_cache) { Redis.new(url: Rails.configuration.x.redis.bank_holidays_url) }

      before do
        bank_holidays_cache.flushdb
        stub_bankholiday_success
      end

      after do
        bank_holidays_cache.flushdb
        bank_holidays_cache.quit
      end

      context "when it's a non-zero day bank holiday" do
        let(:new_time) { Time.zone.local(2025, 12, 25, 13, 0, 0) }

        it_behaves_like "out of hours access"
      end

      context "when it's a zero day bank holiday" do
        let(:new_time) { Time.zone.local(2026, 1, 1, 13, 0, 0) }

        it_behaves_like "out of hours access"
      end
    end

    context "when it's GMT" do
      context "when it's 0630 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 11, 3, 6, 30, 0) }

        it_behaves_like "out of hours access"
      end

      context "when it's 0730 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 11, 3, 7, 30, 0) }

        it_behaves_like "in hours access"
      end

      context "when it's 1830 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 11, 3, 18, 30, 0) }

        it_behaves_like "in hours access"
      end

      context "when it's 2200 on a Monday" do
        let(:new_time) { Time.zone.local(2025, 11, 3, 22, 0, 0) }

        it_behaves_like "out of hours access"
      end
    end
  end
end
