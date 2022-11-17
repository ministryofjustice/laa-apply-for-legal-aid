require "rails_helper"

RSpec.describe Opponents::MentalCapacityForm, type: :form do
  subject(:mental_capacity_form) { described_class.new(form_params) }

  let(:params) do
    {
      "understands_terms_of_court_order" => "false",
      "understands_terms_of_court_order_details" => "New understands terms of court order details",
    }
  end
  let(:opponent) { create(:opponent) }
  let(:form_params) { params.merge(model: opponent) }

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

    it "creates a new opponent" do
      save_form
      expect(opponent.understands_terms_of_court_order_details).to eq "New understands terms of court order details"
    end
  end
end
