require "rails_helper"

RSpec.describe Flow::Steps::LinkedApplications::CopyStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, copy_case:) }
  let(:copy_case) { true }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_link_application_copy_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when the provider confirms they wish to copy the application" do
      it { is_expected.to be :has_national_insurance_numbers }
    end

    context "when the provider confirms they do not wish to copy the application" do
      let(:copy_case) { false }

      it { is_expected.to be :proceedings_types }

      context "and proceedings have already been added to the application" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings) }

        it { is_expected.to be :has_other_proceedings }
      end
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to be :check_provider_answers }
  end
end
