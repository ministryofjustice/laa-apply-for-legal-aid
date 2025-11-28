require "rails_helper"

RSpec.describe HostEnv do
  describe "host_env" do
    before do
      allow(ENV).to receive(:fetch).with("HOST_ENV", nil).and_return("my_host_env")
    end

    it "returns the HOST_ENV envvar values as a symbol" do
      expect(described_class.host_env).to eq :my_host_env
    end
  end

  context "with dummied out local and host environment" do
    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(rails_env.to_s))
    end

    context "when development" do
      let(:rails_env) { :development }

      describe ".environment" do
        it "returns :development" do
          expect(described_class.environment).to eq :development
        end
      end

      context "with interrogations" do
        it "returns the correct values" do
          expect(described_class.development?).to be true
          expect(described_class.test?).to be false
          expect(described_class.uat?).to be false
          expect(described_class.staging?).to be false
          expect(described_class.production?).to be false
          expect(described_class.staging_or_production?).to be false
        end
      end
    end

    context "when test" do
      let(:rails_env) { :test }

      describe ".environment" do
        it "returns :test" do
          expect(described_class.environment).to eq :test
        end
      end

      context "with interrogations" do
        it "returns the correct values" do
          expect(described_class.development?).to be false
          expect(described_class.test?).to be true
          expect(described_class.uat?).to be false
          expect(described_class.staging?).to be false
          expect(described_class.production?).to be false
          expect(described_class.not_production?).to be true
          expect(described_class.staging_or_production?).to be false
        end
      end
    end

    context "when UAT" do
      before do
        allow(ENV).to receive(:fetch).with("HOST_ENV", nil).and_return("uat")
      end

      let(:rails_env) { :production }

      describe ".environment" do
        it "returns :uat" do
          expect(described_class.environment).to eq :uat
        end
      end

      context "with interrogations" do
        it "returns the correct values" do
          expect(described_class.development?).to be false
          expect(described_class.test?).to be false
          expect(described_class.uat?).to be true
          expect(described_class.staging?).to be false
          expect(described_class.production?).to be false
          expect(described_class.not_production?).to be true
          expect(described_class.staging_or_production?).to be false
        end
      end
    end

    context "when staging" do
      before do
        allow(ENV).to receive(:fetch).with("HOST_ENV", nil).and_return("staging")
      end

      let(:rails_env) { :production }

      describe ".environment" do
        it "returns :staging" do
          expect(described_class.environment).to eq :staging
        end
      end

      context "with interrogations" do
        it "returns the correct values" do
          expect(described_class.development?).to be false
          expect(described_class.test?).to be false
          expect(described_class.uat?).to be false
          expect(described_class.staging?).to be true
          expect(described_class.production?).to be false
          expect(described_class.not_production?).to be true
          expect(described_class.staging_or_production?).to be true
        end
      end
    end

    context "when production" do
      before do
        allow(ENV).to receive(:fetch).with("HOST_ENV", nil).and_return("production")
      end

      let(:rails_env) { :production }

      describe ".environment" do
        it "returns :production" do
          expect(described_class.environment).to eq :production
        end
      end

      context "with interrogations" do
        it "returns the correct values" do
          expect(described_class.development?).to be false
          expect(described_class.test?).to be false
          expect(described_class.uat?).to be false
          expect(described_class.staging?).to be false
          expect(described_class.production?).to be true
          expect(described_class.not_production?).to be false
          expect(described_class.staging_or_production?).to be true
        end
      end
    end

    context "when unknown host environment" do
      before do
        allow(ENV).to receive(:fetch).with("HOST_ENV", nil).and_return("foobar")
      end

      let(:rails_env) { :production }

      describe ".environment" do
        it "returns the unknown/unexpected environment" do
          expect(described_class.environment).to eq :foobar
        end
      end

      context "with interrogations" do
        it "returns the correct values" do
          expect(described_class.development?).to be false
          expect(described_class.test?).to be false
          expect(described_class.uat?).to be false
          expect(described_class.staging?).to be false
          expect(described_class.production?).to be false
          expect(described_class.not_production?).to be true
          expect(described_class.staging_or_production?).to be false
        end
      end
    end

    context "when nil host environment" do
      before do
        allow(ENV).to receive(:fetch).with("HOST_ENV", nil).and_return(nil)
      end

      let(:rails_env) { :production }

      describe ".environment" do
        it "raises" do
          expect {
            described_class.environment
          }.to raise_error RuntimeError, "Unable to determine HostEnv from HOST_ENV envar"
        end
      end
    end
  end
end
