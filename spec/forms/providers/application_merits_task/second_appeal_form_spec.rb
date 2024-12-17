require "rails_helper"

RSpec.describe Providers::ApplicationMeritsTask::SecondAppealForm do
  let(:appeal) { create(:appeal, second_appeal: nil) }

  let(:params) do
    {
      model: appeal,
      second_appeal:,
    }
  end

  describe "#validate" do
    subject(:form) { described_class.new(params) }

    context "when second_appeal is blank" do
      let(:second_appeal) { nil }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors).to be_added(:second_appeal, :blank)
        expect(form.errors.messages[:second_appeal]).to include("Select yes if this is a second appeal")
      end
    end

    context "when second_appeal is not blank" do
      let(:second_appeal) { "true" }

      it "is valid" do
        expect(form).to be_valid
      end
    end
  end

  describe "#save" do
    subject(:save_form) { described_class.new(params).save }

    context "when the form is invalid" do
      let(:second_appeal) { nil }

      it "does not update the record" do
        expect { save_form }.not_to change { appeal.reload.second_appeal }.from(nil)
      end
    end

    context "when second_appeal is true" do
      let(:second_appeal) { "true" }

      it "updates the record" do
        expect { save_form }.to change { appeal.reload.second_appeal }.from(nil).to(true)
      end
    end

    context "when second_appeal is false" do
      let(:second_appeal) { "false" }

      it "updates the record" do
        expect { save_form }.to change { appeal.reload.second_appeal }.from(nil).to(false)
      end
    end

    context "when second_appeal previously false and original_judge_level exists" do
      let(:appeal) { create(:appeal, second_appeal: false, original_judge_level: "district_judge") }

      context "when second_appeal changed to true" do
        let(:second_appeal) { "true" }

        it "clears original_judge_level" do
          expect { save_form }.to change { appeal.reload.original_judge_level }.from("district_judge").to(nil)
        end
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { described_class.new(params).save_as_draft }

    context "when the form is invalid" do
      let(:second_appeal) { nil }

      it "does not update the record" do
        expect { save_as_draft }.not_to change { appeal.reload.second_appeal }.from(nil)
      end
    end

    context "when second_appeal is true" do
      let(:second_appeal) { "true" }

      it "updates the record" do
        expect { save_as_draft }.to change { appeal.reload.second_appeal }.from(nil).to(true)
      end
    end

    context "when second_appeal is false" do
      let(:second_appeal) { "false" }

      it "updates the record" do
        expect { save_as_draft }.to change { appeal.reload.second_appeal }.from(nil).to(false)
      end
    end
  end
end
