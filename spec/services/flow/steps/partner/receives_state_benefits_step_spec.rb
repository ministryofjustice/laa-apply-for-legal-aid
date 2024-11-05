require "rails_helper"

RSpec.describe Flow::Steps::Partner::ReceivesStateBenefitsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_partners_receives_state_benefits_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, options) }

    context "when receives_state_benefits is false" do
      let(:options) { { receives_state_benefits: false } }

      it { is_expected.to eq :partner_regular_incomes }
    end

    context "when receives_state_benefits is true" do
      let(:options) { { receives_state_benefits: true } }

      it { is_expected.to eq :partner_state_benefits }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application) }

    before do
      create(:partner, receives_state_benefits:, legal_aid_application:)
    end

    context "when receives_state_benefits is false" do
      let(:receives_state_benefits) { false }

      it { is_expected.to eq :check_income_answers }
    end

    context "when receives_state_benefits is true" do
      let(:receives_state_benefits) { true }

      context "and the state_benefits count is positive" do
        before do
          create(:regular_transaction,
                 transaction_type: create(:transaction_type, :benefits),
                 legal_aid_application:,
                 description: "Test state benefit",
                 owner_id: legal_aid_application.partner.id,
                 owner_type: "Partner")
        end

        it { is_expected.to eq :partner_add_other_state_benefits }
      end

      context "and the state_benefits count is not positive" do
        it { is_expected.to eq :partner_state_benefits }
      end
    end
  end
end
