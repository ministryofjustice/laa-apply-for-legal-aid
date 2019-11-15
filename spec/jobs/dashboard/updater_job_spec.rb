require 'rails_helper'

module Dashboard
  RSpec.describe UpdaterJob do
    describe '.perform' do
      it 'instantiates widget with the specified parameter' do
        expect(Dashboard::Widget).to receive(:new).with('MyWidget').and_return(double('WidgetDataProvider', run: nil))
        UpdaterJob.perform_now('MyWidget')
      end
    end
  end
end
