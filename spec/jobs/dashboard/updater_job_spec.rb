require 'rails_helper'

module Dashboard
  RSpec.describe UpdaterJob do
    let(:suspended_list) { Rails.configuration.x.suspended_dashboard_updater_jobs }

    describe '#perform' do
      context 'job is not in the suspended list' do
        before { allow(HostEnv).to receive(:environment).and_return(:production) }
        it 'instantiates widget with the specified parameter' do
          expect(Dashboard::Widget).to receive(:new).with('MyWidget').and_return(double('WidgetDataProvider', run: nil))
          UpdaterJob.perform_now('MyWidget')
        end
      end

      context 'job is in the suspended list (host environment: test)' do
        it 'does not instantiate widget with the specified parameter' do
          expect(Dashboard::Widget).not_to receive(:new).with('MyWidget')
          UpdaterJob.perform_now('MyWidget')
        end
      end
    end
  end
end
