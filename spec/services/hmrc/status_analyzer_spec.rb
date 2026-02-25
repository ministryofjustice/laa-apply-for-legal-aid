require "rails_helper"

module HMRC
  RSpec.describe StatusAnalyzer do
    describe ".call" do
      before do
        laa.applicant.update!(employed: true) if applicant_employed
        allow(applicant).to receive(:hmrc_responses).and_return(hmrc_response)
      end

      subject(:service_call) { described_class.call(laa) }

      let(:laa) { create(:legal_aid_application, :with_applicant, :with_transaction_period) }
      let(:applicant) { laa.applicant }
      let(:hmrc_response) { [build_stubbed(:hmrc_response)] }

      context "when provider says applicant is not employed" do
        let(:applicant_employed) { false }

        context "and no eligible payments" do
          it { is_expected.to eq :applicant_not_employed_no_payments }
        end

        context "and non-eligible employment payments exist" do
          before { create(:employment, :with_payments_before_transaction_period, legal_aid_application: laa, owner_id: applicant.id, owner_type: applicant.class) }

          it { is_expected.to eq :applicant_not_employed_no_payments }
        end

        context "and applicant has no national insurance number" do
          let(:laa) { create(:legal_aid_application, :with_applicant_no_nino, :with_transaction_period) }

          it { is_expected.to eq :applicant_not_employed_no_nino }
        end

        context "but eligible employment payments exist" do
          before { create(:employment, :with_payments_in_transaction_period, legal_aid_application: laa, owner_id: applicant.id, owner_type: applicant.class) }

          it { is_expected.to eq :applicant_unexpected_employment_data }
        end

        context "and hmrc data is unavailable" do
          let(:hmrc_response) { [] }

          it { is_expected.to eq :applicant_not_employed_hmrc_unavailable }
        end
      end

      context "when provider says applicant is employed" do
        let(:applicant_employed) { true }

        context "and applicant has no national insurance number" do
          let(:laa) { create(:legal_aid_application, :with_applicant_no_nino, :with_transaction_period) }

          it { is_expected.to eq :applicant_employed_no_nino }
        end

        context "and applicant has multiple employments" do
          before { create_list(:employment, 2, :with_payments_in_transaction_period, legal_aid_application: laa, owner_id: applicant.id, owner_type: applicant.class) }

          it { is_expected.to eq :applicant_multiple_employments }
        end

        context "and non-eligible employment payments exist" do
          before { create(:employment, :with_payments_before_transaction_period, legal_aid_application: laa, owner_id: applicant.id, owner_type: applicant.class) }

          it { is_expected.to eq :applicant_unexpected_no_employment_data }
        end

        context "and applicant has single eligible employment" do
          before { create(:employment, :with_payments_in_transaction_period, legal_aid_application: laa, owner_id: applicant.id, owner_type: applicant.class) }

          it { is_expected.to eq :applicant_single_employment }
        end

        context "and hmrc data is unavailable" do
          let(:hmrc_response) { [] }

          it { is_expected.to eq :applicant_employed_hmrc_unavailable }
        end
      end
    end
  end
end
