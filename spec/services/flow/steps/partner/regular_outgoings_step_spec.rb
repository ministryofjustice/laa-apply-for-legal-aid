require "rails_helper"

RSpec.describe Flow::Steps::Partner::RegularOutgoingsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:partner_outgoing_types?) { true }

  before do
    allow(legal_aid_application).to receive(:partner_outgoing_types?).and_return(partner_outgoing_types?)
  end

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_partners_regular_outgoings_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when there are partner outgoing types" do
      it { is_expected.to be :partner_cash_outgoings }
    end

    context "when there are no partner outgoing types" do
      let(:partner_outgoing_types?) { false }

      it { is_expected.to be :has_dependants }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application) }

    context "when there are partner outgoing types" do
      it { is_expected.to be :partner_cash_outgoings }
    end

    context "when there are no partner outgoing types" do
      let(:partner_outgoing_types?) { false }

      it { is_expected.to be :check_income_answers }
    end
  end
end
