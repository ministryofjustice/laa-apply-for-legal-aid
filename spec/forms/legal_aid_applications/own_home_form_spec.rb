require "rails_helper"

RSpec.describe LegalAidApplications::OwnHomeForm, type: :form do
  subject { described_class.new(params.merge(model: application)) }

  let(:application) { create(:legal_aid_application, :with_applicant_and_address) }

  let(:params) { { own_home: "mortgage" } }

  describe "#validate" do
    context "when no params are specified" do
      let(:params) { {} }

      it "raises an error" do
        expect(subject.save).to be false
        expect(subject.errors[:own_home]).to eq [I18n.t("activemodel.errors.models.legal_aid_application.attributes.own_home.blank")]
      end
    end
  end

  describe "#save" do
    let(:params) { { own_home: "mortgage" } }

    it "updates own home attribute" do
      expect(application.own_home).to be_nil
      subject.save
      expect(application.own_home).to eq "mortgage"
    end

    it "leaves other attributes on the record unchanged" do
      expected_attributes = application.attributes.symbolize_keys.except(:state, :own_home, :updated_at, :created_at)
      subject.save
      application.reload
      expected_attributes.each do |attr, val|
        expect(application.send(attr)).to eq(val), "Attr #{attr}: expected #{val}, got #{application.send(attr)}"
      end
    end
  end
end
