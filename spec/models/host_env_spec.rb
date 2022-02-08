require 'rails_helper'

RSpec.describe HostEnv do
  describe 'root_url' do
    it 'returns the root  url' do
      expect(HostEnv.root_url).to eq 'http://www.example.com/?locale=en'
    end
  end

  context 'with dummied out root url' do
    before do
      allow(HostEnv).to receive(:root_url).and_return(root_url)
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(rails_env.to_s))
    end

    context 'development' do
      let(:root_url) { 'http://localhost:3000/' }
      let(:rails_env) { :development }

      describe '.environment' do
        it 'returns :development' do
          expect(HostEnv.environment).to eq :development
        end
      end

      context 'interrogations' do
        it 'returns the correct values' do
          expect(HostEnv.development?).to be true
          expect(HostEnv.test?).to be false
          expect(HostEnv.uat?).to be false
          expect(HostEnv.staging?).to be false
          expect(HostEnv.production?).to be false
          expect(HostEnv.staging_or_production?).to be false
        end
      end
    end

    context 'test' do
      let(:root_url) { 'http://localhost:3000/' }
      let(:rails_env) { :test }

      describe '.environment' do
        it 'returns :test' do
          expect(HostEnv.environment).to eq :test
        end
      end

      context 'interrogations' do
        it 'returns the correct values' do
          expect(HostEnv.development?).to be false
          expect(HostEnv.test?).to be true
          expect(HostEnv.uat?).to be false
          expect(HostEnv.staging?).to be false
          expect(HostEnv.production?).to be false
          expect(HostEnv.staging_or_production?).to be false
        end
      end
    end

    context 'uat' do
      let(:root_url) { 'https://mybranch-applyforlegalaid-uat.apps.live-1.cloud-platform.service.justice.gov.uk' }
      let(:rails_env) { :production }

      describe '.environment' do
        it 'returns :uat' do
          expect(HostEnv.environment).to eq :uat
        end
      end

      context 'interrogations' do
        it 'returns the correct values' do
          expect(HostEnv.development?).to be false
          expect(HostEnv.test?).to be false
          expect(HostEnv.uat?).to be true
          expect(HostEnv.staging?).to be false
          expect(HostEnv.production?).to be false
          expect(HostEnv.staging_or_production?).to be false
        end
      end
    end

    context 'staging' do
      let(:root_url) { 'https://staging.apply-for-legal-aid.service.justice.gov.uk' }
      let(:rails_env) { :production }

      describe '.environment' do
        it 'returns :staging' do
          expect(HostEnv.environment).to eq :staging
        end
      end

      context 'interrogations' do
        it 'returns the correct values' do
          expect(HostEnv.development?).to be false
          expect(HostEnv.test?).to be false
          expect(HostEnv.uat?).to be false
          expect(HostEnv.staging?).to be true
          expect(HostEnv.production?).to be false
          expect(HostEnv.staging_or_production?).to be true
        end
      end
    end

    context 'production' do
      let(:root_url) { 'https://apply-for-legal-aid.service.justice.gov.uk' }
      let(:rails_env) { :production }

      describe '.environment' do
        it 'returns :production' do
          expect(HostEnv.environment).to eq :production
        end
      end

      context 'interrogations' do
        it 'returns the correct values' do
          expect(HostEnv.development?).to be false
          expect(HostEnv.test?).to be false
          expect(HostEnv.uat?).to be false
          expect(HostEnv.staging?).to be false
          expect(HostEnv.production?).to be true
          expect(HostEnv.staging_or_production?).to be true
        end
      end
    end

    context 'unknown environment' do
      let(:root_url) { 'https://example.com' }
      let(:rails_env) { :production }

      describe '.environment' do
        it 'raises' do
          expect {
            HostEnv.environment
          }.to raise_error RuntimeError, 'Unable to determine HostEnv from https://example.com'
        end
      end
    end
  end
end
