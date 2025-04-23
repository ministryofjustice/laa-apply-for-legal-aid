require "rails_helper"

RSpec.describe Applicants::EmployedForm, type: :form do
  subject(:form) { described_class.new(form_params) }

  let(:applicant) { create(:applicant, employed: nil) }
  let(:params) { { employed: true } }
  let(:form_params) { params.merge(model: applicant) }

  describe "#initialize" do
    context "when instantiated with model object that does not have existing checkbox values" do
      let(:params) { {} }
      let(:applicant) { create(:applicant, employed: nil, self_employed: nil, armed_forces: nil) }

      it "initialises values to nil" do
        expect(form).to have_attributes(employed: nil, self_employed: nil, armed_forces: nil)
      end
    end

    context "when instantiated with model object that has existing checkbox values" do
      let(:params) { {} }
      let(:applicant) { create(:applicant, employed: true, self_employed: true, armed_forces: false) }

      it "initialises values to existing model object values" do
        expect(form).to have_attributes(employed: true, self_employed: true, armed_forces: false)
      end
    end
  end

  describe "#validate" do
    context "when no checkbox is selected" do
      let(:params) { {} }

      it "errors" do
        expect(form).to be_invalid
        expect(form.errors[:employed]).to eq [I18n.t("activemodel.errors.models.applicant.attributes.base.none_selected")]
      end
    end

    context "when 'none of the above' and another checkbox are selected" do
      let(:params) { { employed: "true", none_selected: "true" } }

      it "errors" do
        expect(form).to be_invalid
        expect(form.errors[:employed]).to eq [I18n.t("activemodel.errors.models.applicant.attributes.base.none_and_another_option_selected")]
      end
    end
  end

  describe "#save" do
    let(:params) { { employed: "false" } }
    let(:form_params) { params.merge(model: applicant) }

    it "updates record with new value of employed attribute" do
      expect(applicant.employed).to be_nil
      form.save!
      expect(applicant.employed).to be false
    end
  end
end
