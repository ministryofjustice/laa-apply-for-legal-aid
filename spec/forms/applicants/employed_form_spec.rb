require "rails_helper"

RSpec.describe Applicants::EmployedForm, type: :form do
  subject(:described_form) { described_class.new(form_params) }

  let!(:application) { create(:legal_aid_application, applicant:) }
  let(:applicant) { create(:applicant, employed: nil) }

  let(:params) { { employed: true } }
  let(:form_params) { params.merge(model: applicant) }

  describe "validations" do
    let(:params) { {} }

    it "errors if employed not specified" do
      expect(described_form.save).to be false
      expect(described_form.errors[:employed]).to eq [I18n.t("activemodel.errors.models.applicant.attributes.base.none_selected")]
    end
  end

  describe "#save" do
    let(:params) { { employed: "false" } }
    let(:form_params) { params.merge(model: applicant) }

    it "updates record with new value of employed attribute" do
      expect(applicant.employed).to be_nil
      described_form.save
      expect(applicant.employed).to be false
    end
  end
end
