require "rails_helper"
require_relative "shared_examples_for_appeal_court_type_forms"

RSpec.describe Providers::ApplicationMeritsTask::SecondAppealCourtTypeForm do
  let(:appeal) { create(:appeal, second_appeal: true, court_type: nil) }

  let(:params) do
    {
      model: appeal,
      court_type:,
    }
  end

  it_behaves_like "appeal court type selector form"

  # NOTE: This tests difference from shared validation and saving logic only
  describe "#validate" do
    subject(:form) { described_class.new(params) }

    context "when court_type is other_court" do
      let(:court_type) { "other_court" }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors).to be_added(:court_type, :inclusion, value: "other_court")
        expect(form.errors.messages[:court_type]).to include("Select which court the appeal will be heard in from the available list")
      end
    end
  end
end
