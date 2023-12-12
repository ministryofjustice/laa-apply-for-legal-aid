require "rails_helper"

RSpec.describe Applicants::EmployedForm, type: :form do
  subject(:described_form) { described_class.new(form_params) }

  let(:applicant) { create(:applicant, employed: nil) }
  let(:params) { { employed: true } }
  let(:form_params) { params.merge(model: applicant) }

  describe "validations" do
    context "when no checkbox is selected" do
      let(:params) { {} }

      it "errors" do
        expect(described_form.save).to be false
        expect(described_form.errors[:employed]).to eq [I18n.t("activemodel.errors.models.applicant.attributes.base.none_selected")]
      end
    end

    context "when 'none of the above' and another checkbox are selected" do
      let(:params) { { employed: "true", none_selected: "true" } }

      it "errors" do
        expect(described_form.save).to be false
        expect(described_form.errors[:employed]).to eq [I18n.t("activemodel.errors.models.applicant.attributes.base.none_and_another_option_selected")]
      end
    end
  end

  describe "#save" do
    let(:params) { { employed: "false" } }
    let(:form_params) { params.merge(model: applicant) }

    it "updates record with new value of employed attribute" do
      expect(applicant.employed).to be_nil
      described_form.save!
      expect(applicant.employed).to be false
    end
  end
end
