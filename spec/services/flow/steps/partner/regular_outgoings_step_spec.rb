require "rails_helper"

RSpec.describe Flow::Steps::Partner::RegularOutgoingsStep, type: :request do
  let(:application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eql providers_legal_aid_application_partners_regular_outgoings_path(application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(application) }

    context "when there are partner outgoing types" do
      before { allow(application).to receive(:partner_outgoing_types?).and_return(true) }

      it { is_expected.to be :partner_cash_outgoings }
    end

    context "when there are no partner outgoing types and partner makes housing payments" do
      before do
        allow(application).to receive(:partner_outgoing_types?).and_return(false)
        allow(application).to receive(:housing_payments_for?).with("Applicant").and_return(false)
        allow(application).to receive(:housing_payments_for?).with("Partner").and_return(true)
      end

      it { is_expected.to be :housing_benefits }
    end

    context "when there are no partner outgoing types and applicant makes housing payments" do
      before do
        allow(application).to receive(:partner_outgoing_types?).and_return(false)
        allow(application).to receive(:housing_payments_for?).with("Applicant").and_return(true)
        allow(application).to receive(:housing_payments_for?).with("Partner").and_return(false)
      end

      it { is_expected.to be :housing_benefits }
    end

    context "when there are no partner outgoing types and no housing payments" do
      before do
        allow(application).to receive(:partner_outgoing_types?).and_return(false)
        allow(application).to receive(:housing_payments_for?).with("Applicant").and_return(false)
        allow(application).to receive(:housing_payments_for?).with("Partner").and_return(false)
      end

      it { is_expected.to be :has_dependants }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(application) }

    context "when there are partner outgoing types" do
      before do
        allow(application).to receive(:partner_outgoing_types?).and_return(true)
      end

      it { is_expected.to be :partner_cash_outgoings }
    end

    context "when there are no partner outgoing types and partner makes housing payments" do
      before do
        allow(application).to receive(:partner_outgoing_types?).and_return(false)
        allow(application).to receive(:housing_payments_for?).with("Applicant").and_return(false)
        allow(application).to receive(:housing_payments_for?).with("Partner").and_return(true)
      end

      it { is_expected.to be :housing_benefits }
    end

    context "when there are no partner outgoing types and applicant makes housing payments" do
      before do
        allow(application).to receive(:partner_outgoing_types?).and_return(false)
        allow(application).to receive(:housing_payments_for?).with("Applicant").and_return(true)
        allow(application).to receive(:housing_payments_for?).with("Partner").and_return(false)
      end

      it { is_expected.to be :housing_benefits }
    end

    context "when there are no partner outgoing types and no housing payments" do
      before do
        allow(application).to receive(:partner_outgoing_types?).and_return(false)
        allow(application).to receive(:housing_payments_for?).with("Applicant").and_return(false)
        allow(application).to receive(:housing_payments_for?).with("Partner").and_return(false)
      end

      it { is_expected.to be :check_income_answers }
    end
  end
end
