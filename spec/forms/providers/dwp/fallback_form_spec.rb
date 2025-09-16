require "rails_helper"
require_relative "shared_examples_for_override_form"

RSpec.describe Providers::DWP::FallbackForm, type: :form do
  subject(:form) { described_class.new(params) }

  let(:params) { { confirm_dwp_result: nil } }

  describe "validation" do
    it_behaves_like "an overrides_form"

    context "when the parameters are missing" do
      it { is_expected.not_to be_valid }

      context "when not supplied with a persisted Partner instance" do
        it "adds expected error message" do
          form.validate
          expect(form.errors[:confirm_dwp_result]).to include("Select yes if your client gets a passporting benefit")
        end
      end

      context "when supplied with a persisted Partner instance" do
        before { params.merge!(model: create(:partner)) }

        it "adds expected error message" do
          form.validate
          expect(form.errors[:confirm_dwp_result]).to include("Select if your client gets a passporting benefit")
        end
      end
    end
  end
end
