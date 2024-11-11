require "rails_helper"

RSpec.describe Providers::Means::CapitalDisregards::AddDetailsForm do
  subject(:form) { described_class.new(params.merge(model: capital_disregard)) }

  let(:application) { create(:legal_aid_application, :with_applicant, capital_disregards: [capital_disregard]) }
  let(:capital_disregard) { create(:capital_disregard, :discretionary) }

  let(:params) do
    {   payment_reason:,
        amount:,
        account_name:,
        date_received_3i:,
        date_received_2i:,
        date_received_1i: }
  end
  let(:payment_reason) { nil }
  let(:amount) { 123 }
  let(:account_name) { "Barclays" }
  let(:date_received) { Date.new(2024, 2, 1) }
  let(:date_received_3i) { date_received.day }
  let(:date_received_2i) { date_received.month }
  let(:date_received_1i) { date_received.year }

  describe "#save" do
    subject(:call_save) { form.save }

    before { call_save }

    it "is valid" do
      expect(form).to be_valid
    end

    it "updates the capital_disregard" do
      expect(application.capital_disregards.first.amount).to eq 123
      expect(application.capital_disregards.first.account_name).to eq "Barclays"
      expect(application.capital_disregards.first.date_received).to eq Date.new(2024, 2, 1)
    end

    context "when amount is missing" do
      let(:amount) { nil }

      it "is invalid" do
        expect(form).not_to be_valid
      end

      it "adds an error message" do
        error_messages = form.errors.messages.values.flatten
        expect(error_messages).to include(I18n.t("activemodel.errors.models.capital_disregard.attributes.amount.blank"))
      end
    end
  end

  describe "save_as_draft" do
    subject(:call_save_as_draft) { form.save_as_draft }

    before { call_save_as_draft }

    it "is valid" do
      expect(form).to be_valid
    end

    it "updates the capital_disregard" do
      expect(application.capital_disregards.first.amount).to eq 123
      expect(application.capital_disregards.first.account_name).to eq "Barclays"
      expect(application.discretionary_capital_disregards.first.date_received).to eq Date.new(2024, 2, 1)
    end
  end
end
