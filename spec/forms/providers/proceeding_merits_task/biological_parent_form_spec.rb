require "rails_helper"

RSpec.describe Providers::ProceedingMeritsTask::BiologicalParentForm, type: :form do
  subject(:form) { described_class.new(params) }

  let(:params) { { relationship_to_child: } }

  describe "#save" do
    context "with validation" do
      before { form.valid? }

      context "when sent text in the allow list" do
        let(:relationship_to_child) { "biological" }

        it { is_expected.to be_valid }
      end

      context "when sent false" do
        let(:relationship_to_child) { "false" }

        it { is_expected.to be_valid }
      end

      context "when sent unknown text" do
        let(:relationship_to_child) { "unknown" }

        it { is_expected.not_to be_valid }
      end

      context "when sent empty text" do
        let(:relationship_to_child) { "" }

        it { is_expected.not_to be_valid }
      end

      context "when the parameters are missing" do
        let(:relationship_to_child) { nil }

        it { is_expected.not_to be_valid }

        it "records the error message" do
          expect(form.errors[:relationship_to_child]).to eq ["Select yes if your client is the biological parent of any children involved"]
        end
      end
    end

    describe "updates proceeding" do
      subject(:save_form) { form.save }

      let(:proceeding) { create(:proceeding, :pb003) }
      let(:params) { { relationship_to_child:, model: proceeding } }

      context "when sent biological" do
        let(:relationship_to_child) { "biological" }

        it "updates the opponent with our chosen params" do
          save_form
          expect(proceeding).to have_attributes(relationship_to_child: "biological")
          expect(proceeding.reload.relationship_to_child).to eq "biological"
        end
      end

      context "when sent false" do
        let(:relationship_to_child) { "false" }

        it "updates the opponent with our chosen params" do
          save_form
          expect(proceeding.reload.relationship_to_child).to be_nil
        end
      end
    end
  end
end
