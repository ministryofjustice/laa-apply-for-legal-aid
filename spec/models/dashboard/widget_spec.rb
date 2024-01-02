require "rails_helper"

module Dashboard
  module WidgetDataProviders
    class DummyWidgetDataProvider
      def self.handle
        "dummy_widget"
      end

      def self.dataset_definition
        {
          fields: [
            Geckoboard::DateField.new(:date, name: "Date"),
            Geckoboard::NumberField.new(:number, name: "Things"),
          ],
          unique_by: [:date],
        }
      end

      def self.data
        [
          {
            "date" => 7.days.ago.strftime("%Y-%m-%d"),
            "number" => 2,
          },
          {
            "date" => 6.days.ago.strftime("%Y-%m-%d"),
            "number" => 3,
          },
        ]
      end
    end
  end

  RSpec.describe Widget do
    subject(:widget) { described_class.new("DummyWidgetDataProvider") }

    let(:geckoboard_client) { instance_double Geckoboard::Client }
    let(:datasets_client) { instance_double Geckoboard::DatasetsClient }
    let(:dataset) { instance_double Geckoboard::Dataset }
    let(:dummy_data_provider_class) { Dashboard::WidgetDataProviders::DummyWidgetDataProvider }

    before do
      allow(Geckoboard).to receive(:client).and_return(geckoboard_client)
      allow(geckoboard_client).to receive_messages(ping: true, datasets: datasets_client)
    end

    describe "#find_or_create_dataset" do
      before do
        allow(dataset).to receive(:put)
        allow(datasets_client).to receive(:find_or_create)
          .with("apply_for_legal_aid.test.dummy_widget", instance_of(Hash))
          .and_return(dataset)
      end

      it "calls find_or_create on Geckoboard::Datasets" do
        widget.run
        expect(datasets_client).to have_received(:find_or_create)
          .with("apply_for_legal_aid.test.dummy_widget", instance_of(Hash))
      end
    end

    describe "run" do
      before do
        allow(datasets_client).to receive(:find_or_create).and_return(dataset)
      end

      it "sends expected data" do
        expect(dataset).to receive(:put).with(dummy_data_provider_class.data)
        widget.run
      end
    end
  end
end
