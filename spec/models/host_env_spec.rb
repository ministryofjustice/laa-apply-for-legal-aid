require "rails_helper"

RSpec.describe HostEnv do
  describe "root_url" do
    it "returns the root url" do
      expect(described_class.root_url).to eq "http://www.example.com/?locale=en"
    end
  end

  context "with dummied out root url" do
    before do
      allow(described_class).to receive(:root_url).and_return(root_url)
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(rails_env.to_s))
    end

    context "when development" do
      let(:root_url) { "http://localhost:3000/" }
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
      let(:root_url) { "http://localhost:3000/" }
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
      let(:root_url) { "https://mybranch-applyforlegalaid-uat.cloud-platform.service.justice.gov.uk" }
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
      let(:root_url) { "https://staging.apply-for-legal-aid.service.justice.gov.uk" }
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
      let(:root_url) { "https://apply-for-legal-aid.service.justice.gov.uk" }
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

    context "when unknown environment" do
      let(:root_url) { "https://example.com" }
      let(:rails_env) { :production }

      describe ".environment" do
        it "raises" do
          expect {
            described_class.environment
          }.to raise_error RuntimeError, "Unable to determine HostEnv from https://example.com"
        end
      end
    end
  end
end
