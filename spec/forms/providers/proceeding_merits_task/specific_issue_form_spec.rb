require "rails_helper"

RSpec.describe Providers::ProceedingMeritsTask::SpecificIssueForm, type: :form do
  subject(:form) { described_class.new(params) }

  let(:params) do
    {
      details:,
    }
  end

  describe "#save" do
    context "with validation" do
      before { form.valid? }

      context "when the parameters are fully populated" do
        let(:details) { "some detail" }

        it { is_expected.to be_valid }
      end

      context "when the confirmation is selected, but details are omitted" do
        let(:details) { "" }

        it { is_expected.not_to be_valid }

        it "records the error message" do
          expect(form.errors[:details]).to eq ["Enter details of the specific issue"]
        end
      end
    end
  end
end
