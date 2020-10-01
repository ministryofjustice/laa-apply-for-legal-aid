require 'rails_helper'

module Dashboard
  RSpec.describe ProviderDataJob do
    describe '.perform' do
      let(:provider) { create :provider }
      let(:suspended_list) { Rails.configuration.x.suspended_dashboard_updater_jobs }
      subject { described_class.perform_now(provider) }

      let(:geckoboard_client) { double Geckoboard::Client }
      let(:datasets_client) { double Geckoboard::DatasetsClient }
      let(:dataset) { double Geckoboard::Dataset }

      before do
        allow(Geckoboard).to receive(:client).and_return(geckoboard_client)
        allow(geckoboard_client).to receive(:ping).and_return(true)
        allow(geckoboard_client).to receive(:datasets).and_return(datasets_client)
      end

      describe '#perform' do
        context 'job is not in the suspended list' do
          before { allow(HostEnv).to receive(:environment).and_return(:production) }
          it 'calls runs ProviderData' do
            expect_any_instance_of(Dashboard::SingleObject::ProviderData).to receive(:run)
            subject
          end
        end

        context 'job is not in the suspended list' do
          before { allow(HostEnv).to receive(:environment).and_return(:test) }
          it 'does not run ProviderData' do
            expect_any_instance_of(Dashboard::SingleObject::ProviderData).not_to receive(:run)
            subject
          end
        end
      end
    end
  end
end
