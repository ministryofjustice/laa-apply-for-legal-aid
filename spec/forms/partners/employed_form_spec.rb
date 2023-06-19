require "rails_helper"

RSpec.describe Partners::EmployedForm, type: :form do
  subject(:partner_employed_form) { described_class.new(form_params) }

  let(:application) { create(:legal_aid_application, partner:) }
  let(:partner) { create(:partner, employed: nil) }

  let(:params) { { employed: true } }
  let(:form_params) { params.merge(model: partner) }

  describe "validations" do
    let(:params) { {} }

    it "errors if employed not specified" do
      expect(partner_employed_form.save).to be false
      expect(partner_employed_form.errors[:employed]).to eq [I18n.t("activemodel.errors.models.partner.attributes.base.none_selected")]
    end
  end

  describe "#save" do
    let(:params) { { employed: "false" } }

    it "updates record with new value of employed attribute" do
      expect(partner.employed).to be_nil
      partner_employed_form.save!
      expect(partner.employed).to be false
    end
  end
end
