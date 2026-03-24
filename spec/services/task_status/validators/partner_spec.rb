require "rails_helper"
require_relative "task_status_validator_shared_examples"

RSpec.describe TaskStatus::Validators::Partner do
  subject(:validator) { described_class.new(legal_aid_application) }

  let(:legal_aid_application) { create(:application, :with_applicant_and_partner_with_no_contrary_interest) }

  it_behaves_like "a task status validator"

  describe "#valid?" do
    context "with an applicant and partner with no contrary interest" do
      it { is_expected.to be_valid }
    end

    context "when the partner contrary interest question is not answered" do
      let(:legal_aid_application) { create(:application, :with_applicant_and_partner) }

      it { is_expected.not_to be_valid }
    end

    context "when the partner has a contrary interest" do
      before { legal_aid_application.applicant.update!(partner_has_contrary_interest: true) }

      it { is_expected.to be_valid }
    end

    context "when the applicant does not have a partner" do
      let(:legal_aid_application) { create(:application, :with_applicant_and_no_partner) }

      it { is_expected.to be_valid }
    end

    context "when the has_partner question has not been answered" do
      let(:legal_aid_application) { create(:application, :with_applicant) }

      it { is_expected.not_to be_valid }
    end

    context "with no applicant" do
      let(:legal_aid_application) { create(:application) }

      it { is_expected.not_to be_valid }
    end
  end
end
