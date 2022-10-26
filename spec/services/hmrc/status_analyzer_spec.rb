require "rails_helper"

module HMRC
  RSpec.describe StatusAnalyzer do
    describe ".call" do
      subject(:service_call) { described_class.call(laa) }
      before do
        if provider_employed_permissions
          permission = create(:permission, :employed)
          laa.provider.firm.permissions << permission
          laa.provider.permissions << permission
        end
        laa.applicant.update!(employed: true) if applicant_employed
      end

      let(:feature_flag) { true }
      let(:laa) { create(:legal_aid_application, :with_applicant, :with_transaction_period) }
      let(:provider_employed_permissions) { true }
      let(:applicant_employed) { true }

      context "when provider not enabled for employment journey" do
        let(:provider_employed_permissions) { false }

        it "returns provider_not_enabled_for_employed_journey" do
          expect(service_call).to eq :provider_not_enabled_for_employed_journey
        end
      end

      context "when provider_enabled_for_employment journey" do
        context "and applicant not employed and no eligible payments" do
          let(:applicant_employed) { false }

          it "returns not employed" do
            expect(service_call).to eq :applicant_not_employed
          end
        end

        context "with applicant not employed but eligible employment payments exist" do
          let(:applicant_employed) { false }

          before { create(:employment, :with_payments_in_transaction_period, legal_aid_application: laa) }

          it "returns :unexpected_employment_data" do
            expect(service_call).to eq :unexpected_employment_data
          end
        end

        context "with applicant not employed and non-eligible employment payments exist" do
          let(:applicant_employed) { false }

          before { create(:employment, :with_payments_before_transaction_period, legal_aid_application: laa) }

          it "returns :unexpected_employment_data" do
            expect(service_call).to eq :applicant_not_employed
          end
        end

        context "and applicant has multiple employments" do
          before { create_list(:employment, 2, legal_aid_application: laa) }

          it "returns hmrc_multiple_employments" do
            expect(service_call).to eq :hmrc_multiple_employments
          end
        end

        context "and applicant has single employment" do
          before { create(:employment, legal_aid_application: laa) }

          it "returns hmrc_single_employment" do
            expect(service_call).to eq :hmrc_single_employment
          end
        end

        context "but applicant has no hmrc data" do
          it "returns no_hmrc_data" do
            expect(service_call).to eq :no_hmrc_data
          end
        end
      end
    end
  end
end
