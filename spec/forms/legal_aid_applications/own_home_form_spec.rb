require "rails_helper"

RSpec.describe LegalAidApplications::OwnHomeForm, type: :form do
  subject(:described_form) { described_class.new(params.merge(model: application)) }

  let(:application) { create(:legal_aid_application, :with_applicant_and_address) }

  let(:params) { { own_home: "mortgage" } }

  describe "#validate" do
    context "when no params are specified" do
      let(:params) { {} }

      it "raises an error" do
        expect(described_form.save).to be false
        expect(described_form.errors[:own_home]).to eq [I18n.t("activemodel.errors.models.legal_aid_application.attributes.own_home.blank")]
      end
    end
  end

  describe "#save" do
    context "when there are no previously saved values" do
      let(:params) { { own_home: "mortgage" } }

      it "updates own home attribute" do
        expect(application.own_home).to be_nil
        described_form.save!
        expect(application.own_home).to eq "mortgage"
      end

      it "leaves other attributes on the record unchanged" do
        expected_attributes = application.attributes.symbolize_keys.except(:state, :own_home, :updated_at, :created_at)
        described_form.save!
        application.reload
        expected_attributes.each do |attr, val|
          expect(application.send(attr)).to eq(val), "Attr #{attr}: expected #{val}, got #{application.send(attr)}"
        end
      end
    end

    context "when there are previously saved values" do
      let(:application) { create(:legal_aid_application, :with_applicant_and_address, :with_property_values) }

      before do
        described_form.save!
      end

      context "when `mortgage` is selected" do
        let(:params) { { own_home: "mortgage" } }

        it "updates own home attribute" do
          expect(application.own_home).to eq "mortgage"
        end

        it "leaves other attributes on the record unchanged" do
          expected_attributes = application.attributes.symbolize_keys.except(:state, :own_home, :updated_at, :created_at)
          described_form.save!
          application.reload
          expected_attributes.each do |attr, val|
            expect(application.send(attr)).to eq(val), "Attr #{attr}: expected #{val}, got #{application.send(attr)}"
          end
        end
      end

      context "when `owned_outright` is selected" do
        let(:params) { { own_home: "owned_outright" } }

        it "updates own home attribute" do
          expect(application.own_home).to eq "owned_outright"
        end

        it "resets mortgage amount to nil" do
          described_form.save!
          expect(application.outstanding_mortgage_amount).to be_nil
        end
      end

      context "when `no` is selected" do
        let(:params) { { own_home: "no" } }

        it "updates own home attribute" do
          expect(application.own_home).to eq "no"
        end

        it "resets all property values to nil" do
          described_form.save!
          expect(application.property_value).to be_nil
          expect(application.outstanding_mortgage_amount).to be_nil
          expect(application.shared_ownership).to be_nil
          expect(application.percentage_home).to be_nil
        end
      end
    end
  end
end
