require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::ConfirmNonMeansTestedApplicationStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, copy_case:) }
  let(:proceeding) { create(:proceeding, :da001, client_involvement_type_ccms_code:) }
  let(:client_involvement_type_ccms_code) { "A" }
  let(:copy_case) { true }

  before { legal_aid_application.proceedings << proceeding }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_confirm_non_means_tested_applications_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when the application has been copied from another application" do
      context "when the application is not an sca application" do
        it { is_expected.to eq :check_merits_answers }

        context "when the application is an sca application" do
          let(:proceeding) { create(:proceeding, :pb059, client_involvement_type_ccms_code:) }

          it { is_expected.to eq :check_merits_answers }

          context "when the application has proceedings with the respondent CIT" do
            let(:client_involvement_type_ccms_code) { "D" }

            it { is_expected.to eq :merits_task_lists }
          end
        end
      end
    end

    context "when the application has not been copied from another application" do
      let(:copy_case) { false }

      it { is_expected.to eq :merits_task_lists }
    end
  end
end
