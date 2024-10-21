require "rails_helper"

RSpec.describe Flow::Steps::Partner::CashOutgoingsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_partners_cash_outgoing_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    before do
      allow(legal_aid_application).to receive(:housing_payments_for?).with("Applicant").and_return(applicant_housing_payments?)
      allow(legal_aid_application).to receive(:housing_payments_for?).with("Partner").and_return(partner_housing_payments?)
    end

    context "when only the applicant has housing payments" do
      let(:applicant_housing_payments?) { true }
      let(:partner_housing_payments?) { false }

      it { is_expected.to be :housing_benefits }
    end

    context "when only the partner has housing payments" do
      let(:applicant_housing_payments?) { false }
      let(:partner_housing_payments?) { true }

      it { is_expected.to be :housing_benefits }
    end

    context "when both the applicant and partner have housing payments" do
      let(:applicant_housing_payments?) { true }
      let(:partner_housing_payments?) { true }

      it { is_expected.to be :housing_benefits }
    end

    context "when there are no housing payments" do
      let(:applicant_housing_payments?) { false }
      let(:partner_housing_payments?) { false }

      it { is_expected.to be :has_dependants }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application) }

    before do
      allow(legal_aid_application).to receive(:housing_payments_for?).with("Applicant").and_return(applicant_housing_payments?)
      allow(legal_aid_application).to receive(:housing_payments_for?).with("Partner").and_return(partner_housing_payments?)
    end

    context "when only the applicant has housing payments" do
      let(:applicant_housing_payments?) { true }
      let(:partner_housing_payments?) { false }

      it { is_expected.to be :housing_benefits }
    end

    context "when only the partner has housing payments" do
      let(:applicant_housing_payments?) { false }
      let(:partner_housing_payments?) { true }

      it { is_expected.to be :housing_benefits }
    end

    context "when both the applicant and partner have housing payments" do
      let(:applicant_housing_payments?) { true }
      let(:partner_housing_payments?) { true }

      it { is_expected.to be :housing_benefits }
    end

    context "when there are no housing payments" do
      let(:applicant_housing_payments?) { false }
      let(:partner_housing_payments?) { false }

      it { is_expected.to be :has_dependants }
    end
  end
end
