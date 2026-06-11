require "rails_helper"

RSpec.describe Autograntable do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }
  let(:applicant) { create(:applicant, age_for_means_test_purposes: 16) }
  let(:proceeding) { create(:proceeding, :pb059, client_involvement_type_ccms_code:, legal_aid_application: legal_aid_application) }
  let(:client_involvement_type_ccms_code) { "W" }

  before { legal_aid_application.proceedings << proceeding }

  context "when there are special children act proceedings" do
    context "when there is a valid combination of proceedings" do
      context "when there is a single autograntable core proceeding" do
        it { is_expected.to be true }
      end

      context "when the application has a care order and a supervision order proceeding" do
        let(:care_order_proceeding) { create(:proceeding, :pb057, legal_aid_application:) }

        before { legal_aid_application.proceedings << care_order_proceeding }

        it { is_expected.to be true }
      end
    end

    context "when the application does not have a valid combination of proceedings to be autogranted" do
      let(:proceeding) { create(:proceeding, :pb057, legal_aid_application:) }
      let(:emergency_protection_order_proceeding) { create(:proceeding, :pb026, legal_aid_application:) }

      before { legal_aid_application.proceedings << emergency_protection_order_proceeding }

      it { is_expected.to be false }
    end

    context "when the applicant is a child subject with a supervision order proceeding and over 17" do
      let(:applicant) { create(:applicant, age_for_means_test_purposes: 17) }

      it { is_expected.to be false }
    end
  end

  context "when there are no special children act proceedings" do
    let(:proceeding) { create(:proceeding, :da001, legal_aid_application:) }

    it { is_expected.to be false }
  end
end
