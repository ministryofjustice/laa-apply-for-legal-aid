require "rails_helper"

module Providers
  module ProceedingMeritsTask
    RSpec.describe ChancesOfSuccessForm do
      subject(:form) { described_class.new(params) }

      let(:chances_of_success) { create(:chances_of_success, proceeding:) }
      let(:proceeding) { create(:proceeding, :pbm32) }

      let(:params) do
        {
          model: chances_of_success,
          proceeding_id: proceeding.id,
          success_likely:,
          success_prospect_details:,
        }
      end

      let(:success_likely) { "true" }
      let(:success_prospect_details) { nil }

      describe "#validate" do
        context "when success_likely is true" do
          let(:success_likely) { "true" }

          it { is_expected.to be_valid }
        end

        context "when success_likely is false" do
          let(:success_likely) { "false" }

          context "and details are provided" do
            let(:success_prospect_details) { "reasons" }

            it { is_expected.to be_valid }
          end

          context "and details are not provided" do
            it { is_expected.not_to be_valid }
          end
        end
      end

      describe "#save" do
        subject(:save_form) { form.save }

        context "when the form is invalid" do
          context "with success_likelymissing" do
            let(:success_likely) { nil }

            it "does not update the record" do
              expect { save_form }.not_to change(chances_of_success, :success_likely).from(nil)
            end
          end

          context "and success_likely is false but success_prospect_details is missing" do
            let(:success_likely) { "false" }

            it "does not update the record" do
              expect { save_form }.not_to change(chances_of_success, :success_likely).from(nil)
            end
          end
        end

        context "when success_likely is true" do
          it "updates the record" do
            expect { save_form }.to change(chances_of_success, :success_likely).from(nil).to(true)
          end
        end

        context "when success_likely is false" do
          let(:success_likely) { "false" }

          context "and details are provided" do
            let(:success_prospect_details) { "reasons" }

            it "updates the record" do
              expect { save_form }.to change(chances_of_success, :success_likely).from(nil).to(false)
                                      .and change(chances_of_success, :success_prospect_details).from(nil).to("reasons")
            end
          end
        end

        context "when success_likely changed from false with reasons to true" do
          let(:chances_of_success) do
            create(:chances_of_success,
                   proceeding:,
                   success_likely: false,
                   success_prospect: "not_known",
                   success_prospect_details: "reasons")
          end

          it "updates the record" do
            expect { save_form }.to change(chances_of_success, :success_likely).from(false).to(true)
                                      .and change(chances_of_success, :success_prospect_details).from("reasons").to(nil)
                                      .and change(chances_of_success, :success_prospect).from("not_known").to("likely")
          end
        end
      end

      describe "#save_as_draft" do
        subject(:save_form) { form.save_as_draft }

        context "when the form is invalid" do
          context "with success_likely missing" do
            let(:success_likely) { nil }

            it "does not update the record" do
              expect { save_form }.not_to change(chances_of_success, :success_likely).from(nil)
            end
          end

          context "and success_likely is false but success_prospect_details is missing" do
            let(:success_likely) { "false" }

            it "updates success_likely" do
              expect { save_form }.to change(chances_of_success, :success_likely).from(nil)
            end
          end
        end

        context "when success_likely is true" do
          it "updates the record" do
            expect { save_form }.to change(chances_of_success, :success_likely).from(nil).to(true)
          end
        end

        context "when success_likely is false" do
          let(:success_likely) { "false" }

          context "and details are provided" do
            let(:success_prospect_details) { "reasons" }

            it "updates the record" do
              expect { save_form }.to change(chances_of_success, :success_likely).from(nil).to(false)
                                      .and change(chances_of_success, :success_prospect_details).from(nil).to("reasons")
            end
          end
        end
      end
    end
  end
end
