require "rails_helper"

RSpec.describe Flow::Steps::Partner::EmployedStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_partners_employed_index_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when partner is self_employed" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_self_employed_partner) }

      it { is_expected.to be :partner_use_ccms_employment }
    end

    context "when partner is in the armed_forces" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner_in_armed_forces) }

      it { is_expected.to be :partner_use_ccms_employment }
    end

    context "when partner is employed and has no nino" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_employed_partner_no_nino) }

      it { is_expected.to be :partner_full_employment_details }
    end

    context "when partner is not_employed" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner_not_employed) }

      it { is_expected.to be :partner_bank_statements }
    end
  end
end
