require "rails_helper"

RSpec.describe CapitalDisregard do
  let(:capital_disregard) { create(:capital_disregard) }

  describe "incomplete?" do
    subject { capital_disregard.incomplete? }

    let(:capital_disregard) do
      create(:capital_disregard,
             :discretionary,
             payment_reason:,
             name:,
             amount:,
             account_name:,
             date_received:)
    end

    let(:payment_reason) { "Reason" }
    let(:name) { "backdated_benefits" }
    let(:amount) { 123 }
    let(:account_name) { "Barclays" }
    let(:date_received) { Date.new(2024, 0o1, 0o1) }

    context "when name is not compensation_for_personal_harm or loss_or_harm_relating_to_this_application" do
      context "when all fields are filled in" do
        it { is_expected.to be false }
      end

      context "when date received is nil" do
        let(:date_received) { nil }

        it { is_expected.to be true }
      end

      context "when amount is nil" do
        let(:amount) { nil }

        it { is_expected.to be true }
      end

      context "when account_name is nil" do
        let(:account_name) { nil }

        it { is_expected.to be true }
      end

      context "when payment_reason is nil" do
        let(:payment_reason) { nil }

        it { is_expected.to be false }
      end
    end

    context "when name is compensation_for_personal_harm and payment_reason is nil" do
      let(:name) { "compensation_for_personal_harm" }
      let(:payment_reason) { nil }

      it { is_expected.to be true }
    end
  end
end
