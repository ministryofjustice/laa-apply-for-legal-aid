require "rails_helper"

RSpec.describe Providers::ApplicationMeritsTask::OriginalJudgeLevelForm do
  let(:appeal) { create(:appeal, original_judge_level: nil) }

  let(:params) do
    {
      model: appeal,
      original_judge_level:,
    }
  end

  describe "#validate" do
    subject(:form) { described_class.new(params) }

    context "when original_judge_level is valid value" do
      let(:original_judge_level) { "district_judge" }

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when original_judge_level is blank" do
      let(:original_judge_level) { nil }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors).to be_added(:original_judge_level, :blank)
        expect(form.errors.messages[:original_judge_level]).to include("Select what level of judge heard the original case")
      end
    end

    context "when original_judge_level is invalid value" do
      let(:original_judge_level) { "foobar" }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors).to be_added(:original_judge_level, :inclusion, value: "foobar")
        expect(form.errors.messages[:original_judge_level]).to include("Select what level of judge heard the original case from the available list")
      end
    end
  end

  describe "#save" do
    subject(:save_form) { described_class.new(params).save }

    context "when the form is blank" do
      let(:original_judge_level) { nil }

      it "does not update the record" do
        expect { save_form }.not_to change { appeal.reload.original_judge_level }.from(nil)
      end
    end

    context "when the form is invalid" do
      let(:original_judge_level) { "foobar" }

      it "does not update the record" do
        expect { save_form }.not_to change { appeal.reload.original_judge_level }.from(nil)
      end
    end

    context "when original_judge_level is valid" do
      let(:original_judge_level) { "district_judge" }

      it "updates the record" do
        expect { save_form }.to change { appeal.reload.original_judge_level }.from(nil).to("district_judge")
      end
    end

    context "when value changed" do
      let(:appeal) { create(:appeal, original_judge_level: "family_panel_magistrates") }
      let(:original_judge_level) { "district_judge" }

      it "updates the record" do
        expect { save_form }.to change { appeal.reload.original_judge_level }
          .from("family_panel_magistrates")
          .to("district_judge")
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { described_class.new(params).save_as_draft }

    context "when the form is blank" do
      let(:original_judge_level) { nil }

      it "does not update the record" do
        expect { save_as_draft }.not_to change { appeal.reload.original_judge_level }.from(nil)
      end
    end

    context "when original_judge_level is valid" do
      let(:original_judge_level) { "district_judge" }

      it "updates the record" do
        expect { save_as_draft }.to change { appeal.reload.original_judge_level }.from(nil).to("district_judge")
      end
    end
  end
end
