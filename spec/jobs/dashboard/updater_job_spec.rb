require 'rails_helper'

module Dashboard
  RSpec.describe UpdaterJob do
    let(:suspended_list) { Rails.configuration.x.suspended_dashboard_updater_jobs }

    describe '#perform' do
      context 'job is not in the suspended list' do
        before {allow(suspended_list).to receive(:include?).with('Dashboard::UpdaterJob').and_return(false) }
        it 'instantiates widget with the specified parameter' do
          expect(Dashboard::Widget).to receive(:new).with('MyWidget').and_return(double('WidgetDataProvider', run: nil))
          UpdaterJob.perform_now('MyWidget')
        end
      end

      context 'job is not in the suspended list' do
        before {allow(suspended_list).to receive(:include?).with('Dashboard::UpdaterJob').and_return(true) }
        it 'does not instantiate widget with the specified parameter' do
          expect(Dashboard::Widget).not_to receive(:new).with('MyWidget')
          UpdaterJob.perform_now('MyWidget')
        end
      end
    end
  end
end
