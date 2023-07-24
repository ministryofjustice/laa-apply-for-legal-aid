require "rails_helper"

module HMRC
  RSpec.describe PartnerStatusAnalyzer do
    describe ".call" do
      subject(:service_call) { described_class.call(laa) }
      before { laa.partner.update!(employed: true) if partner_employed }

      let(:feature_flag) { true }
      let(:laa) { create(:legal_aid_application, :with_applicant_and_partner, :with_transaction_period) }
      let(:partner) { laa.partner }
      let(:partner_employed) { true }

      context "and partner not employed and no eligible payments" do
        let(:partner_employed) { false }

        it "returns not employed" do
          expect(service_call).to eq :partner_not_employed
        end
      end

      context "with partner not employed but eligible employment payments exist" do
        let(:partner_employed) { false }

        before { create(:employment, :with_payments_in_transaction_period, legal_aid_application: laa, owner_id: partner.id, owner_type: partner.class) }

        it "returns :unexpected_employment_data" do
          expect(service_call).to eq :partner_unexpected_employment_data
        end
      end

      context "with partner not employed and non-eligible employment payments exist" do
        let(:partner_employed) { false }

        before { create(:employment, :with_payments_before_transaction_period, legal_aid_application: laa, owner_id: partner.id, owner_type: partner.class) }

        it "returns :unexpected_employment_data" do
          expect(service_call).to eq :partner_not_employed
        end
      end

      context "and partner has multiple employments" do
        before { create_list(:employment, 2, legal_aid_application: laa, owner_id: partner.id, owner_type: partner.class) }

        it "returns partner_multiple_employments" do
          expect(service_call).to eq :partner_multiple_employments
        end
      end

      context "and partner has single employment" do
        before { create(:employment, legal_aid_application: laa, owner_id: partner.id, owner_type: partner.class) }

        it "returns partner_hmrc_single_employment" do
          expect(service_call).to eq :partner_single_employment
        end
      end

      context "but partner has no hmrc data" do
        it "returns partner_no_hmrc_data" do
          expect(service_call).to eq :partner_no_hmrc_data
        end
      end

      context "and applicant has hmrc data but partner does not" do
        let(:applicant) { laa.applicant }

        before { create(:employment, legal_aid_application: laa, owner_id: applicant.id, owner_type: applicant.class) }

        it "returns partner_no_hmrc_data" do
          expect(service_call).to eq :partner_no_hmrc_data
        end
      end
    end
  end
end
