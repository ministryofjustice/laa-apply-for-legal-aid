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
      Setting.setting.update!(service_maintenance_mode: true)
      Rails.application.reload_routes!
    end

    after do
      Setting.setting.update!(service_maintenance_mode: false)
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

    context "when /ping request made" do
      before { get "/ping" }

      it { expect(response).to be_ok }
    end

    context "when /healthcheck request made" do
      before do
        allow(Sidekiq::ProcessSet).to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, size: 1))
        allow(Sidekiq::RetrySet).to receive(:new).and_return(instance_double(Sidekiq::RetrySet, size: 0))
        allow(Sidekiq::DeadSet).to receive(:new).and_return(instance_double(Sidekiq::DeadSet, size: 0))
        connection = instance_double(HTTPClient::Connection)
        allow(connection).to receive(:info).and_return(redis_version: "7.0.0")
        allow(Sidekiq).to receive(:redis).and_yield(connection)
        get "/healthcheck"
      end

      it { expect(response).to be_ok }
    end
  end
end
