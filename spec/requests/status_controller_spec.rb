require "rails_helper"

RSpec.describe StatusController, :clamav do
  describe "#healthcheck" do
    before do
      allow(Sidekiq::ProcessSet).to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, size: 1))
      allow(Sidekiq::RetrySet).to receive(:new).and_return(instance_double(Sidekiq::RetrySet, size: 0))
      allow(Sidekiq::DeadSet).to receive(:new).and_return(instance_double(Sidekiq::DeadSet, size: 0))
      client = instance_double(Sidekiq::RedisClientAdapter::CompatClient)
      allow(client).to receive(:info).and_return(redis_version: "5.0.0")
      allow(Sidekiq).to receive(:redis).and_yield(client)
    end

    context "when failed Sidekiq jobs exist" do
      let(:failed_job_healthcheck) do
        {
          checks: {
            database: true,
            redis: true,
            sidekiq: true,
            sidekiq_queue: false,
            malware_scanner: {
              positive: true,
              negative: true,
            },
          },
        }.to_json
      end

      context "and dead set exists" do
        before do
          allow(Sidekiq::DeadSet).to receive(:new).and_return(instance_double(Sidekiq::DeadSet, size: 1))
          get "/healthcheck"
        end

        it "returns ok http status" do
          expect(response).to have_http_status :ok
        end

        it "returns the expected response report" do
          expect(response.body).to eq(failed_job_healthcheck)
        end
      end

      context "and retry set exists" do
        before do
          allow(Sidekiq::RetrySet).to receive(:new).and_return(instance_double(Sidekiq::RetrySet, size: 1))
          get "/healthcheck"
        end

        it "returns ok http status" do
          expect(response).to have_http_status :ok
        end

        it "returns the expected response report" do
          expect(response.body).to eq(failed_job_healthcheck)
        end
      end
    end

    context "when an sidekiq/redis problem exists" do
      before do
        allow(ActiveRecord::Base.connection).to receive(:database_exists?).and_return(true)
        allow(Sidekiq::ProcessSet).to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, size: 0))

        client = instance_double(Sidekiq::RedisClientAdapter::CompatClient)
        allow(client).to receive(:info).and_raise(Redis::CannotConnectError)
        allow(Sidekiq).to receive(:redis).and_yield(client)

        get "/healthcheck"
      end

      let(:failed_healthcheck) do
        {
          checks: {
            database: true,
            redis: false,
            sidekiq: false,
            sidekiq_queue: true,
            malware_scanner: {
              positive: true,
              negative: true,
            },
          },
        }.to_json
      end

      it "returns status bad gateway" do
        expect(response).to have_http_status :bad_gateway
      end

      it "returns the expected response report" do
        expect(response.body).to eq(failed_healthcheck)
      end
    end

    context "when database not available" do
      before do
        allow(ActiveRecord::Base.connection).to receive(:database_exists?).and_return(false)
        allow(Sidekiq::ProcessSet).to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, size: 1))

        client = instance_double(Sidekiq::RedisClientAdapter::CompatClient)
        allow(client).to receive(:info).and_return("some info about redis")
        allow(Sidekiq).to receive(:redis).and_yield(client)

        get "/healthcheck"
      end

      let(:failed_healthcheck) do
        {
          checks: {
            database: false,
            redis: true,
            sidekiq: true,
            sidekiq_queue: true,
            malware_scanner: {
              positive: true,
              negative: true,
            },
          },
        }.to_json
      end

      it "returns status bad gateway" do
        expect(response).to have_http_status :bad_gateway
      end

      it "returns the expected response report" do
        expect(response.body).to eq(failed_healthcheck)
      end
    end

    context "when Sidekiq::ProcessSet encounters an error" do
      before do
        allow(Sidekiq::ProcessSet).to receive(:new).and_raise(StandardError)

        get "/healthcheck"
      end

      let(:failed_healthcheck) do
        {
          checks: {
            database: true,
            redis: true,
            sidekiq: false,
            sidekiq_queue: true,
            malware_scanner: {
              positive: true,
              negative: true,
            },
          },
        }.to_json
      end

      it "returns status bad gateway" do
        expect(response).to have_http_status :bad_gateway
      end

      it "returns the expected response report" do
        expect(response.body).to eq(failed_healthcheck)
      end
    end

    context "when sidekiq_queue_healthy encounters an error" do
      before do
        allow(Sidekiq::DeadSet).to receive(:new).and_raise(StandardError)

        get "/healthcheck"
      end

      let(:failed_healthcheck) do
        {
          checks: {
            database: true,
            redis: true,
            sidekiq: true,
            sidekiq_queue: false,
            malware_scanner: {
              positive: true,
              negative: true,
            },
          },
        }.to_json
      end

      it "returns ok http status" do
        # queue health should not impact the status
        expect(response).to have_http_status :ok
      end

      it "returns the expected response report" do
        expect(response.body).to eq(failed_healthcheck)
      end
    end

    context "when everything is ok" do
      before do
        allow(ActiveRecord::Base.connection).to receive(:active?).and_return(true)

        client = instance_double(Sidekiq::RedisClientAdapter::CompatClient, info: {})
        allow(Sidekiq).to receive(:redis).and_yield(client)

        get "/healthcheck"
      end

      let(:expected_response) do
        {
          checks: {
            database: true,
            redis: true,
            sidekiq: true,
            sidekiq_queue: true,
            malware_scanner: {
              positive: true,
              negative: true,
            },
          },
        }.to_json
      end

      it "returns HTTP success" do
        get "/healthcheck"
        expect(response).to have_http_status(:ok)
      end

      it "returns the expected response report" do
        get "/healthcheck"
        expect(response.body).to eq(expected_response)
      end
    end
  end

  describe "#ping" do
    context "when environment variables set" do
      let(:expected_json) do
        {
          "build_date" => "20150721",
          "build_tag" => "test",
          "app_branch" => "test_branch",
        }
      end

      before do
        allow(Rails.configuration.x.status).to receive_messages(build_date: "20150721", build_tag: "test", app_branch: "test_branch")
        get("/ping")
      end

      it "returns JSON with app information" do
        expect(response.parsed_body).to eq(expected_json)
      end
    end

    context "when environment variables not set" do
      before do
        allow(Rails.configuration.x.status).to receive_messages(build_date: "Not Available", build_tag: "Not Available", app_branch: "Not Available")

        get "/ping"
      end

      it 'returns "Not Available"' do
        expect(response.parsed_body.values).to be_all("Not Available")
      end
    end
  end
end
