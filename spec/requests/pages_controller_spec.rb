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
end
