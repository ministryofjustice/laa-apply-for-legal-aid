require 'rails_helper'

RSpec.describe HostingEnvironment do
  context 'testing environment' do
    describe '.env' do
      it 'returns :test' do
        expect(HostingEnvironment.env).to eq :test
      end
    end

    describe '.test?' do
      it 'is true' do
        expect(HostingEnvironment.test?).to be true
      end
    end

    describe '.development?' do
      it 'is false' do
        expect(HostingEnvironment.development?).to be false
      end
    end

    describe '.uat?' do
      it 'is false' do
        expect(HostingEnvironment.uat?).to be false
      end
    end

    describe '.staging?' do
      it 'is false' do
        expect(HostingEnvironment.staging?).to be false
      end
    end

    describe '.live?' do
      it 'is false' do
        expect(HostingEnvironment.live?).to be false
      end
    end
  end

  context 'development environment' do
    before do
      allow(Rails.env).to receive(:development?).and_return(true)
      allow(Rails.env).to receive(:test?).and_return(false)
    end
    describe '.env' do
      it 'returns :development' do
        expect(HostingEnvironment.env).to eq :development
      end
    end

    describe '.test?' do
      it 'is false' do
        expect(HostingEnvironment.test?).to be false
      end
    end

    describe '.development?' do
      it 'is true' do
        expect(HostingEnvironment.development?).to be true
      end
    end

    describe '.uat?' do
      it 'is false' do
        expect(HostingEnvironment.uat?).to be false
      end
    end

    describe '.staging?' do
      it 'is false' do
        expect(HostingEnvironment.staging?).to be false
      end
    end

    describe '.live?' do
      it 'is false' do
        expect(HostingEnvironment.live?).to be false
      end
    end
  end

  context 'uat environment' do
    before do
      allow(Rails.env).to receive(:test?).and_return(false)
    end

    describe '.env' do
      it 'returns :uat' do
        with_modified_env uat_env do
          expect(HostingEnvironment.env).to eq :uat
        end
      end
    end

    describe '.test?' do
      it 'is false' do
        with_modified_env uat_env do
          expect(HostingEnvironment.test?).to be false
        end
      end
    end

    describe '.development?' do
      it 'is false' do
        with_modified_env uat_env do
          expect(HostingEnvironment.development?).to be false
        end
      end
    end

    describe '.uat?' do
      it 'is true' do
        with_modified_env uat_env do
          expect(HostingEnvironment.uat?).to be true
        end
      end
    end

    describe '.staging?' do
      it 'is false' do
        with_modified_env uat_env do
          expect(HostingEnvironment.staging?).to be false
        end
      end
    end

    describe '.live?' do
      it 'is false' do
        with_modified_env uat_env do
          expect(HostingEnvironment.live?).to be false
        end
      end
    end
  end

  context 'staging' do
    before do
      allow(Rails.env).to receive(:test?).and_return(false)
    end

    describe '.env' do
      it 'returns :staging' do
        with_modified_env staging_env do
          expect(HostingEnvironment.env).to eq :staging
        end
      end
    end

    describe '.test?' do
      it 'is false' do
        with_modified_env staging_env do
          expect(HostingEnvironment.test?).to be false
        end
      end
    end

    describe '.development?' do
      it 'is false' do
        with_modified_env staging_env do
          expect(HostingEnvironment.development?).to be false
        end
      end
    end

    describe '.uat?' do
      it 'is false' do
        with_modified_env staging_env do
          expect(HostingEnvironment.uat?).to be false
        end
      end
    end

    describe '.staging?' do
      it 'is true' do
        with_modified_env staging_env do
          expect(HostingEnvironment.staging?).to be true
        end
      end
    end

    describe '.live?' do
      it 'is false' do
        with_modified_env staging_env do
          expect(HostingEnvironment.live?).to be false
        end
      end
    end
  end

  context 'live' do
    before do
      allow(Rails.env).to receive(:test?).and_return(false)
    end

    describe '.env' do
      it 'returns :live' do
        with_modified_env live_env do
          expect(HostingEnvironment.env).to eq :live
        end
      end
    end

    describe '.test?' do
      it 'is false' do
        with_modified_env live_env do
          expect(HostingEnvironment.test?).to be false
        end
      end
    end

    describe '.development?' do
      it 'is false' do
        with_modified_env live_env do
          expect(HostingEnvironment.development?).to be false
        end
      end
    end

    describe '.uat?' do
      it 'is false' do
        with_modified_env live_env do
          expect(HostingEnvironment.uat?).to be false
        end
      end
    end

    describe '.staging?' do
      it 'is false' do
        with_modified_env live_env do
          expect(HostingEnvironment.staging?).to be false
        end
      end
    end

    describe '.live?' do
      it 'is true' do
        with_modified_env live_env do
          expect(HostingEnvironment.live?).to be true
        end
      end
    end
  end

  context 'unknown host name' do
    before do
      allow(Rails.env).to receive(:test?).and_return(false)
    end

    it 'raises an exception' do
      with_modified_env unknown_env do
        expect {
          HostingEnvironment.env
        }.to raise_error RuntimeError, 'Unknown Host Environment'
      end
    end

    it 'returns false for all other methods' do
      with_modified_env unknown_env do
        expect(HostingEnvironment.test?).to be false
        expect(HostingEnvironment.development?).to be false
        expect(HostingEnvironment.staging?).to be false
        expect(HostingEnvironment.live?).to be false
        expect(HostingEnvironment.uat?).to be false
      end
    end
  end

  def uat_env
    {
      HOST: 'ap-296-submitted-applicant-rea-applyforlegalaid-uat.apps.cloud-platform-live-0.k8s.integration.dsd.io'
    }
  end

  def staging_env
    {
      HOST: 'applyforlegalaid-staging.apps.cloud-platform-live-0.k8s.integration.dsd.io'
    }
  end

  def live_env
    {
      HOST: 'applyforlegalaid.apps.cloud-platform-live-0.k8s.integration.dsd.io'
    }
  end

  def unknown_env
    {
      HOST: 'unknown-env.apps.cloud-platform-live-0.k8s.integration.dsd.io'
    }
  end
end
