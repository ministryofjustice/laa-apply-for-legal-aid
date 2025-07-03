require "rails_helper"
require_relative "task_status_validator_shared_examples"

RSpec.describe TaskStatus::Validators::ProceedingsTypes, :vcr do
  subject(:validator) { described_class.new(application) }

  let(:application) do
    create(
      :application,
      :with_proceedings,
      :with_delegated_functions_on_proceedings,
      explicit_proceedings: %i[da001 se013],
      df_options: { DA001: [5.days.ago, 5.days.ago], SE013: [2.days.ago, 2.days.ago] },
    )
  end

  it_behaves_like "a task status validator"

  describe "#valid?" do
    context "when there are no proceedings" do
      let(:application) { create(:application) }

      it { is_expected.not_to be_valid }
    end

    context "with single proceeding" do
      before do
        application.proceedings.find_by(ccms_code: "DA001").destroy!
      end

      context "with a client involvement type" do
        it { is_expected.to be_valid }
      end

      context "without a client involvement type" do
        before do
          application.proceedings.find_by(ccms_code: "SE013").update!(
            client_involvement_type_ccms_code: nil,
            client_involvement_type_description: nil,
          )
          application.proceedings.reload
        end

        it { is_expected.not_to be_valid }
      end
    end

    context "with multiple proceedings" do
      context "with one proceeding with client involvement type and one without" do
        before do
          application.proceedings.find_by(ccms_code: "SE013").update!(
            client_involvement_type_ccms_code: nil,
            client_involvement_type_description: nil,
          )
          application.proceedings.reload
        end

        it { is_expected.not_to be_valid }
      end

      context "when delegated functions question has not been answered for each proceeding" do
        before do
          application.proceedings.find_by(ccms_code: "SE013").update!(
            used_delegated_functions: nil,
            used_delegated_functions_on: nil,
          )
          application.proceedings.reload
        end

        it { is_expected.not_to be_valid }
      end

      context "when delegated functions question has been answered for each proceeding" do
        it { is_expected.to be_valid }
      end
    end
  end
end
