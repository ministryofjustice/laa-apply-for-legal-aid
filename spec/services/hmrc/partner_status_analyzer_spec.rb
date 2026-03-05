require "rails_helper"

module HMRC
  RSpec.describe PartnerStatusAnalyzer do
    describe ".call" do
      before do
        laa.partner.update!(employed: true) if partner_employed
        allow(partner).to receive(:hmrc_responses).and_return(hmrc_response)
      end

      subject(:service_call) { described_class.call(laa) }

      let(:laa) { create(:legal_aid_application, :with_applicant_and_partner, :with_transaction_period) }
      let(:partner) { laa.partner }
      let(:hmrc_response) { [build_stubbed(:hmrc_response)] }

      context "when provider says partner is not employed" do
        let(:partner_employed) { false }

        context "and no eligible payments" do
          it { is_expected.to eq :partner_not_employed_no_payments }
        end

        context "and non-eligible employment payments exist" do
          before { create(:employment, :with_payments_before_transaction_period, legal_aid_application: laa, owner_id: partner.id, owner_type: partner.class) }

          it { is_expected.to eq :partner_not_employed_no_payments }
        end

        context "and partner has no national insurance number" do
          let(:laa) { create(:legal_aid_application, :with_partner_no_nino, :with_transaction_period) }

          it { is_expected.to eq :partner_not_employed_no_nino }
        end

        context "but eligible employment payments exist" do
          before { create(:employment, :with_payments_in_transaction_period, legal_aid_application: laa, owner_id: partner.id, owner_type: partner.class) }

          it { is_expected.to eq :partner_unexpected_employment_data }
        end

        context "and hmrc data is unavailable" do
          let(:hmrc_response) { [] }

          it { is_expected.to eq :partner_not_employed_hmrc_unavailable }
        end
      end

      context "when provider says partner is employed" do
        let(:partner_employed) { true }

        context "and partner has no national insurance number" do
          let(:laa) { create(:legal_aid_application, :with_partner_no_nino, :with_transaction_period) }

          it { is_expected.to eq :partner_employed_no_nino }
        end

        context "and partner has multiple employments" do
          before { create_list(:employment, 2, :with_payments_in_transaction_period, legal_aid_application: laa, owner_id: partner.id, owner_type: partner.class) }

          it { is_expected.to eq :partner_multiple_employments }
        end

        context "and non-eligible employment payments exist" do
          before { create(:employment, :with_payments_before_transaction_period, legal_aid_application: laa, owner_id: partner.id, owner_type: partner.class) }

          it { is_expected.to eq :partner_unexpected_no_employment_data }
        end

        context "and partner has single eligible employment" do
          before { create(:employment, :with_payments_in_transaction_period, legal_aid_application: laa, owner_id: partner.id, owner_type: partner.class) }

          it { is_expected.to eq :partner_single_employment }
        end

        context "and hmrc data is unavailable" do
          let(:hmrc_response) { [] }

          it { is_expected.to eq :partner_employed_hmrc_unavailable }
        end
      end

      context "and applicant has hmrc data but partner does not" do
        let(:applicant) { laa.applicant }
        let(:partner_employed) { false }

        before { create(:employment, :with_payments_in_transaction_period, legal_aid_application: laa, owner_id: applicant.id, owner_type: applicant.class) }

        it { is_expected.to eq :partner_not_employed_no_payments }
      end
    end
  end
end
