require "rails_helper"

RSpec.describe Providers::ProceedingMeritsTask::SpecificIssueForm, type: :form do
  subject(:form) { described_class.new(params) }

  let(:params) do
    {
      confirmed:,
      details:,
    }
  end

  describe "#save" do
    context "with validation" do
      before { form.valid? }

      context "when the parameters are fully populated" do
        let(:details) { "some detail" }
        let(:confirmed) { true }

        it { is_expected.to be_valid }
      end

      context "when the confirmation is not selected" do
        let(:details) { "some detail" }
        let(:confirmed) { false }

        it { is_expected.not_to be_valid }

        it "records the error message" do
          expect(form.errors[:confirmed]).to eq ["You must confirm this specific issue proceeding is not for a change of name application"]
        end
      end

      context "when the confirmation is selected, but details are omitted" do
        let(:details) { "" }
        let(:confirmed) { true }

        it { is_expected.not_to be_valid }

        it "records the error message" do
          expect(form.errors[:details]).to eq ["Enter details of the specific issue"]
        end
      end
    end
  end
end
