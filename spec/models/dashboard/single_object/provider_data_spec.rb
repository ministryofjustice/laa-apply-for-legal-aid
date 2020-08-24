require 'rails_helper'

module Dashboard
  module SingleObject
    RSpec.describe ProviderData do
      subject(:dashboard_provider) { described_class.new(provider) }

      let(:geckoboard_client) { double Geckoboard::Client }
      let(:datasets_client) { double Geckoboard::DatasetsClient }
      let(:dataset) { double Geckoboard::Dataset }

      before do
        allow(Geckoboard).to receive(:client).and_return(geckoboard_client)
        allow(geckoboard_client).to receive(:ping).and_return(true)
        allow(geckoboard_client).to receive(:datasets).and_return(datasets_client)
      end

      let(:application) { create :legal_aid_application, :with_applicant }
      let(:provider) { application.provider }

      it { is_expected.to be_a Dashboard::SingleObject::ProviderData }

      describe '.build_row' do
        subject(:build_row) { dashboard_provider.build_row }

        let(:expected_response) do
          [
            {
              reference: provider.id,
              timestamp: provider.created_at,
              firm: provider.firm.name,
              count: 1
            }
          ]
        end

        it 'returns an array summarising the application' do
          is_expected.to eql expected_response
        end
      end

      describe '.run' do
        subject(:run) { dashboard_provider.run }

        it 'submits data to geckoboard' do
          expect(datasets_client).to receive(:find_or_create).and_return(dataset)
          expect(dataset).to receive(:post)
          run
        end
      end
    end
  end
end
