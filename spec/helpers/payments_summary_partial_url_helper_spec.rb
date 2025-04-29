require "rails_helper"

RSpec.describe PaymentsSummaryPartialUrlHelper do
  let(:application) { create(:legal_aid_application) }
  let(:partner) { false }
  let(:credit) { false }
  let(:regular_payments) { false }

  describe ".payments_summary_partial_url" do
    subject(:helper_method) { payments_summary_partial_url(partner, credit, regular_payments, application) }

    context "when partner=true and credit=true" do
      let(:partner) { true }
      let(:credit) { true }

      it "returns the url for partner regular incomes page" do
        expect(helper_method).to match "/providers/applications/#{application.id}/partners/regular_incomes?locale=en"
      end
    end

    context "when partner=true and credit=false" do
      let(:partner) { true }
      let(:credit) { false }

      it "returns the url for partner regular outgoings page" do
        expect(helper_method).to match "/providers/applications/#{application.id}/partners/regular_outgoings?locale=en"
      end
    end

    context "when partner=false and credit=true and regular_payments=false" do
      let(:partner) { false }
      let(:credit) { true }

      it "returns the url for client identify types of incomes page" do
        expect(helper_method).to match "/providers/applications/#{application.id}/means/identify_types_of_income?locale=en"
      end
    end

    context "when partner=false and credit=false and regular_payments=false" do
      let(:partner) { false }
      let(:credit) { false }

      it "returns the url for client identify types of outgoings page" do
        expect(helper_method).to match "/providers/applications/#{application.id}/means/identify_types_of_outgoing?locale=en"
      end
    end

    context "when partner=false and credit=true and regular_payments=true" do
      let(:partner) { false }
      let(:credit) { true }
      let(:regular_payments) { true }

      it "returns the url for client regular outgoings page" do
        expect(helper_method).to match "/providers/applications/#{application.id}/means/regular_incomes?locale=en"
      end
    end

    context "when partner=false and credit=false and regular_payments=true" do
      let(:partner) { false }
      let(:credit) { false }
      let(:regular_payments) { true }

      it "returns the url for client regular outgoings page" do
        expect(helper_method).to match "/providers/applications/#{application.id}/means/regular_outgoings?locale=en"
      end
    end
  end
end
