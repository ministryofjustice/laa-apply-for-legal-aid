require "rails_helper"

module Dashboard
  module WidgetDataProviders
    RSpec.describe NumberProviderFirms do
      describe ".handle" do
        it "returns the unqualified widget name" do
          expect(described_class.handle).to eq "number_provider_firms"
        end
      end

      describe ".dataset_definition" do
        it "returns hash of field definitions" do
          expected_definition = '{"fields":[{"name":"Firms","optional":false,"type":"number"}]}'
          expect(described_class.dataset_definition.to_json).to eq expected_definition
        end
      end

      describe ".data" do
        context "when no one has ever logged in" do
          let(:expected_data) { [{ "number" => 0 }] }

          it "sends expected data" do
            expect(described_class.data).to eq expected_data
          end
        end

        context "with five users over three firms" do
          let(:first_firm) { create(:firm) }
          let(:second_firm) { create(:firm) }
          let(:third_firm) { create(:firm) }

          before do
            create(:provider, username: "user1-first_firm", firm: first_firm)
            create(:provider, username: "user2-first_firm", firm: first_firm)
            create(:provider, username: "user1-second_firm", firm: second_firm)
            create(:provider, username: "user2-second_firm", firm: second_firm)
            create(:provider, username: "user1-third_firm", firm: third_firm)
          end

          it "expects the firm count to include all firms" do
            expect(described_class.data).to eq [{ "number" => 3 }]
          end
        end
      end
    end
  end
end
