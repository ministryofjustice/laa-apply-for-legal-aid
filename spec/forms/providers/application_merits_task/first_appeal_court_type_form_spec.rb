require "rails_helper"
require_relative "shared_examples_for_appeal_court_type_forms"

RSpec.describe Providers::ApplicationMeritsTask::FirstAppealCourtTypeForm do
  let(:appeal) { create(:appeal, second_appeal: false, court_type: nil) }

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

      it "is valid" do
        expect(form).to be_valid
      end
    end
  end
end
