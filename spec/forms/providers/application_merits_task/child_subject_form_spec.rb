require "rails_helper"

RSpec.describe Providers::ApplicationMeritsTask::ChildSubjectForm, type: :form do
  subject(:form) { described_class.new(params) }

  let(:params) { { relationship_to_children: } }

  describe "#save" do
    context "with validation" do
      before { form.valid? }

      context "when sent text in the allow list" do
        let(:relationship_to_children) { "child_subject" }

        it { is_expected.to be_valid }
      end

      context "when sent false" do
        let(:relationship_to_children) { "false" }

        it { is_expected.to be_valid }
      end

      context "when sent an empty string" do
        let(:relationship_to_children) { "" }

        it { is_expected.not_to be_valid }
      end

      context "when sent unknown text" do
        let(:relationship_to_children) { "unknown" }

        it { is_expected.not_to be_valid }
      end

      context "when the parameters are missing" do
        let(:relationship_to_children) { nil }

        it { is_expected.not_to be_valid }

        it "records the error message" do
          expect(form.errors[:relationship_to_children]).to eq ["Select yes if your client is a child subject of the proceeding"]
        end
      end
    end
  end
end
