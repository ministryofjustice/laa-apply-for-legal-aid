require "rails_helper"
require_relative "shared_examples_for_override_form"

RSpec.describe Providers::DWP::FallbackForm, type: :form do
  subject(:form) { described_class.new(params) }

  let(:params) { { confirm_dwp_result: nil } }

  describe "validation" do
    it_behaves_like "an overrides_form"

    context "when the parameters are missing" do
      it { is_expected.not_to be_valid }

      it "adds expected error message" do
        form.validate
        expect(form.errors[:confirm_dwp_result]).to include("Select yes if the DWP records are correct")
      end
    end
  end
end
