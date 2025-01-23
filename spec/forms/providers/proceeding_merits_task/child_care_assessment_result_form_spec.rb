require "rails_helper"

module Providers
  module ProceedingMeritsTask
    RSpec.describe ChildCareAssessmentResultForm do
      subject(:form) { described_class.new(params) }

      let(:child_care_assessment) { create(:child_care_assessment, assessed: nil, proceeding:) }
      let(:proceeding) { create(:proceeding, :pbm32) }

      let(:params) do
        {
          model: child_care_assessment,
          proceeding_id: proceeding.id,
          result:,
          details:,
        }
      end

      let(:result) { "true" }
      let(:details) { nil }

      describe "#validate" do
        context "with positive result value present" do
          let(:result) { "true" }

          it { is_expected.to be_valid }
        end

        context "with negative result and details value present" do
          let(:result) { "false" }
          let(:details) { "negative result challenge..." }

          it { is_expected.to be_valid }
        end

        context "with result attribute missing" do
          let(:result) { "" }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors).to be_added(:result, :inclusion, value: "")
            expect(form.errors.messages[:result]).to include("Select if the assessment was positive or negative")
            expect(form.errors.messages[:details]).to be_empty
          end

          context "when saving as draft" do
            before { allow(form).to receive(:draft?).and_return(true) }

            it { is_expected.to be_valid }
          end
        end

        context "with negative result but details missing" do
          let(:result) { "false" }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors).to be_added(:details, :blank)
            expect(form.errors.messages[:details]).to include("Enter how the negative assessment will be challenged")
          end

          context "when saving as draft" do
            before { allow(form).to receive(:draft?).and_return(true) }

            it { is_expected.to be_valid }
          end
        end
      end

      describe "#save" do
        subject(:save_form) { described_class.new(params).save }

        context "when the form is invalid" do
          let(:result) { nil }

          it "does not update the record" do
            expect { save_form }.not_to change(child_care_assessment, :result).from(nil)
          end
        end

        context "when result is true" do
          let(:result) { "true" }

          it "updates the record" do
            expect { save_form }.to change(child_care_assessment, :result).from(nil).to(true)
          end
        end

        context "when result is false but no details provided" do
          let(:result) { "false" }

          it "does NOT update the record" do
            expect { save_form }.not_to change(child_care_assessment, :result).from(nil)
          end
        end

        context "when result is false and details provided" do
          let(:result) { "false" }
          let(:details) { "negative assessment challenged..." }

          it "updates the record" do
            expect { save_form }.to change { child_care_assessment.reload.attributes.symbolize_keys }
              .from(hash_including(result: nil, details: nil))
              .to(hash_including(result: false, details: instance_of(String)))
          end
        end

        context "when result changed from false to true and details exist" do
          let(:child_care_assessment) do
            create(:child_care_assessment,
                   assessed: true,
                   result: false,
                   details: "negative assessment result reason",
                   proceeding:)
          end

          let(:result) { "true" }

          it "clears assessment result details" do
            expect { save_form }.to change(child_care_assessment, :details).from(instance_of(String)).to(nil)
          end
        end

        context "when result changed from true to false" do
          let(:child_care_assessment) do
            create(:child_care_assessment,
                   assessed: true,
                   result: true,
                   details: nil,
                   proceeding:)
          end

          let(:result) { "false" }

          it "does not change assessment result details" do
            expect { save_form }.not_to change(child_care_assessment, :details).from(nil)
          end
        end
      end

      describe "#save_as_draft" do
        subject(:save_as_draft) { described_class.new(params).save_as_draft }

        context "when the form is invalid" do
          let(:result) { nil }

          it "does not update the record" do
            expect { save_as_draft }.not_to change(child_care_assessment, :result).from(nil)
          end
        end

        context "when result is true" do
          let(:result) { "true" }

          it "updates the record" do
            expect { save_as_draft }.to change(child_care_assessment, :result).from(nil).to(true)
          end
        end

        context "when result is false but no details provided" do
          let(:result) { "false" }

          it "updates the record" do
            expect { save_as_draft }.to change(child_care_assessment, :result).from(nil).to(false)
          end
        end

        context "when result is false and details provided" do
          let(:result) { "false" }
          let(:details) { "negative assessment challenged..." }

          it "updates the record" do
            expect { save_as_draft }.to change { child_care_assessment.reload.attributes.symbolize_keys }
              .from(hash_including(result: nil, details: nil))
              .to(hash_including(result: false, details: instance_of(String)))
          end
        end

        context "when result changed from false to true and details exist" do
          let(:child_care_assessment) do
            create(:child_care_assessment,
                   assessed: true,
                   result: false,
                   details: "negative assessment result reason",
                   proceeding:)
          end

          let(:result) { "true" }

          it "clears assessment result details" do
            expect { save_as_draft }.to change(child_care_assessment, :details).from(instance_of(String)).to(nil)
          end
        end

        context "when result changed from true to false" do
          let(:child_care_assessment) do
            create(:child_care_assessment,
                   assessed: true,
                   result: true,
                   details: nil,
                   proceeding:)
          end

          let(:result) { "false" }

          it "does not change assessment result details" do
            expect { save_as_draft }.not_to change(child_care_assessment, :details).from(nil)
          end
        end
      end
    end
  end
end
