require "rails_helper"

RSpec.describe LiquidCapitalItemsHelper do
  describe "#capital_items_to_display?" do
    subject(:call) { capital_items_to_display?(legal_aid_application, item) }

    context "with passported application without online accounts item description" do
      let(:legal_aid_application) { create(:legal_aid_application, :passported) }
      let(:item) { { description: "foobar" } }

      it { is_expected.to be true }
    end

    context "with passported application with online account item description" do
      let(:legal_aid_application) { create(:legal_aid_application, :passported) }
      let(:item) { { description: "Online current accounts" } }

      it { is_expected.to be false }
    end

    context "with non-passported application" do
      let(:legal_aid_application) { create(:legal_aid_application, :non_passported) }
      let(:item) { { description: "irrelevant" } }

      it { is_expected.to be true }
    end
  end

  describe "#item_description" do
    subject(:call) { item_description(legal_aid_application, item) }

    context "with passported application" do
      let(:legal_aid_application) { create(:legal_aid_application, :passported) }
      let(:item) { { description: "foobar" } }

      it "returns item description" do
        expect(call).to eql "foobar"
      end
    end

    context "with non-passported application and saving account item description" do
      let(:legal_aid_application) { create(:legal_aid_application, :non_passported) }
      let(:item) { { description: "Savings accounts" } }

      it { is_expected.to eql "Savings accounts your client cannot access online" }
    end
  end
end
