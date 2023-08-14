require "rails_helper"

RSpec.describe Vehicles::DetailsForm, :vcr, type: :form do
  subject(:vehicle_details_form) { described_class.new(form_params) }

  let(:model) { create(:vehicle) }
  let(:params) do
    {
      estimated_value:,
      more_than_three_years_old:,
      payment_remaining:,
      payments_remain:,
      used_regularly:,
    }
  end
  let(:estimated_value) { "" }
  let(:more_than_three_years_old) { "" }
  let(:payment_remaining) { "" }
  let(:payments_remain) { "" }
  let(:used_regularly) { "" }

  let(:form_params) { params.merge(model:) }

  describe "#validate" do
    context "when no params are specified" do
      it "raises an error" do
        expect(vehicle_details_form.valid?).to be false
        expect(vehicle_details_form.errors.messages).to match_array(
          estimated_value: ["Enter the estimated value of the vehicle"],
          more_than_three_years_old: ["Select yes if the vehicle was bought over 3 years ago"],
          payments_remain: ["Select yes if there are any payments left on the vehicle"],
          used_regularly: ["Select yes if the vehicle is in regular use"],
        )
      end
    end

    context "when values are provided" do
      let(:estimated_value) { "5000.00" }
      let(:more_than_three_years_old) { "false" }
      let(:payment_remaining) { "true" }
      let(:payments_remain) { "1000" }
      let(:used_regularly) { "true" }

      it "does not raise any errors" do
        expect(vehicle_details_form.valid?).to be true
        expect(vehicle_details_form.errors).to be_empty
      end
    end
  end

  describe "#save" do
    subject(:save_form) { vehicle_details_form.save }

    let(:estimated_value) { 5000.00 }
    let(:more_than_three_years_old) { "false" }
    let(:payments_remain) { "true" }
    let(:payment_remaining) { 1000 }
    let(:used_regularly) { "true" }

    context "when the parameters are all valid" do
      before { save_form }

      it "updates the vehicle" do
        expect(model.reload).to have_attributes(
          estimated_value: 5000,
          more_than_three_years_old: false,
          payment_remaining: 1000,
          used_regularly: true,
        )
      end
    end

    context "when the payment_remaining is false and payments_remain is set" do
      let(:payments_remain) { "false" }

      before { save_form }

      it "updates the vehicle and blanks the remaining payments" do
        expect(model.reload).to have_attributes(
          estimated_value: 5000,
          more_than_three_years_old: false,
          payment_remaining: 0,
          used_regularly: true,
        )
      end
    end
  end
end
