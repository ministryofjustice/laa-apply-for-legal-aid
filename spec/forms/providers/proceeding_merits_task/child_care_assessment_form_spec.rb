require "rails_helper"

module Providers
  module ProceedingMeritsTask
    RSpec.describe ChildCareAssessmentForm do
      subject(:form) { described_class.new(params) }

      let(:child_care_assessment) { create(:child_care_assessment, assessed: nil, proceeding:) }
      let(:proceeding) { create(:proceeding, :pbm32) }

      let(:params) do
        {
          model: child_care_assessment,
          proceeding_id: proceeding.id,
          assessed:,
        }
      end

      let(:assessed) { "true" }

      describe "#validate" do
        context "with assessed value present" do
          let(:assessed) { "true" }

          it { is_expected.to be_valid }
        end

        context "with assessed attribute missing" do
          let(:assessed) { "" }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors).to be_added(:assessed, :inclusion, value: "")
            expect(form.errors.messages[:assessed]).to include("Select yes if the local authority has assessed your client's ability to care for the children involved")
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
          let(:assessed) { nil }

          it "does not update the record" do
            expect { save_form }.not_to change(child_care_assessment, :assessed).from(nil)
          end
        end

        context "when assessed is true" do
          let(:assessed) { "true" }

          it "updates the record" do
            expect { save_form }.to change(child_care_assessment, :assessed).from(nil).to(true)
          end
        end

        context "when assessed is false" do
          let(:assessed) { "false" }

          it "updates the record" do
            expect { save_form }.to change(child_care_assessment, :assessed).from(nil).to(false)
          end
        end

        context "when assessed changed from true to false and result and details exist" do
          let(:child_care_assessment) do
            create(:child_care_assessment,
                   assessed: true,
                   result: false,
                   details: "negative assessment result reason",
                   proceeding:)
          end

          let(:assessed) { "false" }

          it "clears assessment result" do
            expect { save_form }.to change(child_care_assessment, :result).from(false).to(nil)
          end

          it "clears assessment result details" do
            expect { save_form }.to change(child_care_assessment, :details).from(instance_of(String)).to(nil)
          end
        end

        context "when assessed changed from false to true" do
          let(:child_care_assessment) do
            create(:child_care_assessment,
                   assessed: false,
                   result: nil,
                   details: nil,
                   proceeding:)
          end

          let(:assessed) { "false" }

          it "does not change assessment result" do
            expect { save_form }.not_to change(child_care_assessment, :result).from(nil)
          end

          it "does not change assessment result details" do
            expect { save_form }.not_to change(child_care_assessment, :details).from(nil)
          end
        end
      end

      describe "#save_as_draft" do
        subject(:save_as_draft) { described_class.new(params).save_as_draft }

        context "when the form is invalid" do
          let(:assessed) { nil }

          it "does not update the record" do
            expect { save_as_draft }.not_to change(child_care_assessment, :assessed).from(nil)
          end
        end

        context "when assessed is true" do
          let(:assessed) { "true" }

          it "updates the record" do
            expect { save_as_draft }.to change(child_care_assessment, :assessed).from(nil).to(true)
          end
        end

        context "when assessed is false" do
          let(:assessed) { "false" }

          it "updates the record" do
            expect { save_as_draft }.to change(child_care_assessment, :assessed).from(nil).to(false)
          end
        end

        context "when assessed changed from true to false and result and details exist" do
          let(:child_care_assessment) do
            create(:child_care_assessment,
                   assessed: true,
                   result: false,
                   details: "negative assessment result reason",
                   proceeding:)
          end

          let(:assessed) { "false" }

          it "clears assessment result" do
            expect { save_as_draft }.to change(child_care_assessment, :result).from(false).to(nil)
          end

          it "clears assessment result details" do
            expect { save_as_draft }.to change(child_care_assessment, :details).from(instance_of(String)).to(nil)
          end
        end

        context "when assessed changed from false to true" do
          let(:child_care_assessment) do
            create(:child_care_assessment,
                   assessed: false,
                   result: nil,
                   details: nil,
                   proceeding:)
          end

          let(:assessed) { "false" }

          it "does not change assessment result" do
            expect { save_as_draft }.not_to change(child_care_assessment, :result).from(nil)
          end

          it "does not change assessment result details" do
            expect { save_as_draft }.not_to change(child_care_assessment, :details).from(nil)
          end
        end
      end
    end
  end
end
