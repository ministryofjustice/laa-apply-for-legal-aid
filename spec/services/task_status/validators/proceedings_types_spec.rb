require "rails_helper"
require_relative "task_status_validator_shared_examples"

RSpec.describe TaskStatus::Validators::ProceedingsTypes, :vcr do
  subject(:validator) { described_class.new(application) }

  let(:application) do
    create(
      :application,
      :with_proceedings,
      :with_delegated_functions_on_proceedings,
      explicit_proceedings: %i[da001 se014],
      df_options: { DA001: [5.days.ago, 5.days.ago], SE014: [2.days.ago, 2.days.ago] },
    )
  end

  before do
    application.proceedings.all.update!(
      accepted_emergency_defaults: true,
    )
    application.proceedings.reload
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
          application.proceedings.find_by(ccms_code: "SE014").update!(
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
          application.proceedings.find_by(ccms_code: "SE014").update!(
            client_involvement_type_ccms_code: nil,
            client_involvement_type_description: nil,
          )
          application.proceedings.reload
        end

        it { is_expected.not_to be_valid }
      end

      context "when delegated functions question has not been answered for each proceeding" do
        before do
          application.proceedings.find_by(ccms_code: "SE014").update!(
            used_delegated_functions: nil,
            used_delegated_functions_on: nil,
          )
          application.proceedings.reload
        end

        it { is_expected.not_to be_valid }
      end

      context "when delegated functions question has been answered for each proceeding" do
        it { is_expected.to be_valid }

        context "and emergency certificate is not used" do
          it { is_expected.to be_valid }
        end

        context "and emergency certificate is used" do
          context "and emergency application has not been answered" do
            before do
              application.proceedings.find_by(ccms_code: "SE014").update!(
                accepted_emergency_defaults: nil,
                emergency_level_of_service: nil,
                emergency_level_of_service_name: nil,
                emergency_level_of_service_stage: nil,
              )
              application.proceedings.reload
            end

            it { is_expected.not_to be_valid }
          end
        end
      end
    end
  end
end
