require "rails_helper"

RSpec.describe Opponents::MentalCapacityForm, type: :form do
  subject(:mental_capacity_form) { described_class.new(form_params) }

  let(:params) do
    {
      "understands_terms_of_court_order" => "false",
      "understands_terms_of_court_order_details" => "New understands terms of court order details",
    }
  end
  let(:parties_mental_capacity) { create(:parties_mental_capacity) }
  let(:form_params) { params.merge(model: parties_mental_capacity) }

  describe "validation" do
    subject(:valid_form) { mental_capacity_form.valid? }

    it "when the params are complete" do
      expect(valid_form).to be true
    end

    context "when the details are incomplete" do
      let(:params) do
        {
          "understands_terms_of_court_order" => "false",
          "understands_terms_of_court_order_details" => "",
        }
      end

      it { is_expected.to be false }
    end
  end

  describe "#save" do
    subject(:save_form) { mental_capacity_form.save }

    it "updates the opponent with our chosen params" do
      save_form
      expect(parties_mental_capacity).to have_attributes(
        understands_terms_of_court_order: false,
        understands_terms_of_court_order_details: "New understands terms of court order details",
      )
    end
  end
end
