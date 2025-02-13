require "rails_helper"

RSpec.describe Providers::ApplicationMeritsTask::BiologicalParentForm, type: :form do
  subject(:form) { described_class.new(params) }

  let(:params) { { relationship_to_children: } }

  describe "#save" do
    context "with validation" do
      before { form.valid? }

      context "when sent text in the allow list" do
        let(:relationship_to_children) { "biological" }

        it { is_expected.to be_valid }
      end

      context "when sent false" do
        let(:relationship_to_children) { "false" }

        it { is_expected.to be_valid }
      end

      context "when sent unknown text" do
        let(:relationship_to_children) { "unknown" }

        it { is_expected.not_to be_valid }
      end

      context "when sent empty text" do
        let(:relationship_to_children) { "" }

        it { is_expected.not_to be_valid }
      end

      context "when the parameters are missing" do
        let(:relationship_to_children) { nil }

        it { is_expected.not_to be_valid }

        it "records the error message" do
          expect(form.errors[:relationship_to_children]).to eq ["Select yes if your client is the biological parent of any children involved"]
        end
      end
    end

    describe "updates applicant" do
      subject(:save_form) { form.save }

      let(:applicant) { create(:applicant) }
      let(:params) { { relationship_to_children:, model: applicant } }

      context "when sent biological" do
        let(:relationship_to_children) { "biological" }

        it "updates the opponent with our chosen params" do
          save_form
          expect(applicant).to have_attributes(relationship_to_children: "biological")
          expect(applicant.reload.relationship_to_children).to eq "biological"
        end
      end

      context "when sent false" do
        let(:relationship_to_children) { "false" }

        it "updates the opponent with our chosen params" do
          save_form
          expect(applicant.reload.relationship_to_children).to be_nil
        end
      end
    end
  end
end
