require "rails_helper"

RSpec.describe LegalAidApplications::PropertyDetailsForm, type: :form do
  subject(:described_form) { described_class.new(params.merge(model: legal_aid_application)) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_address) }

  let(:params) do
    {
      property_value:,
      outstanding_mortgage_amount: "20",
      shared_ownership: "friend_family_member_or_other_individual",
      percentage_home:,
    }
  end
  let(:property_value) { "10,000" }
  let(:percentage_home) { "85" }

  describe "#validate" do
    context "when no params are specified" do
      let(:params) { {} }

      it "raises an error" do
        expect(described_form.save).to be false
        expect(described_form.errors[:property_value]).to eq ["Enter how much the home your client lives in is worth"]
        expect(described_form.errors[:outstanding_mortgage_amount]).to eq ["Enter how much is left to pay on the mortgage"]
        expect(described_form.errors[:shared_ownership]).to eq ["Select yes if your client owns the home with anyone else"]
        expect(described_form.errors[:percentage_home]).to eq ["Enter what percentage of the house your client legally owns"]
      end
    end

    describe "property_value" do
      before { described_form.valid? }

      context "when the value is non numeric" do
        let(:property_value) { "BOB" }

        it { expect(described_form.errors[:property_value]).to eq ["Enter the amount the home is worth, like 1,000 or 20.30"] }
      end

      context "when the value is below zero" do
        let(:property_value) { "-50,000" }

        it { expect(described_form.errors[:property_value]).to eq ["How much the home your client lives in in must be 0 or more"] }
      end

      context "when the value has too many decimals" do
        let(:property_value) { "10,000.050" }

        it { expect(described_form.errors[:property_value]).to eq ["The value of the home your client lives in cannot include more than 2 decimal places"] }
      end
    end

    describe "percentage_home" do
      before { described_form.valid? }

      context "when the value is non numeric" do
        let(:percentage_home) { "BOB" }

        it { expect(described_form.errors[:percentage_home]).to eq ["The percentage of the house your client legally owns must be between 0 and 100, like 60"] }
      end

      context "when the value is below zero" do
        let(:percentage_home) { "-50" }

        it { expect(described_form.errors[:percentage_home]).to eq ["The percentage of the house your client legally owns must be between 0 and 100, like 60"] }
      end

      context "when the value is above 100" do
        let(:percentage_home) { "110" }

        it { expect(described_form.errors[:percentage_home]).to eq ["The percentage of the house your client legally owns must be between 0 and 100, like 60"] }
      end
    end
  end

  describe "#save" do
    it "updates the legal aid application property attributes" do
      expect(legal_aid_application.property_value).to be_nil
      expect(legal_aid_application.outstanding_mortgage_amount).to be_nil
      expect(legal_aid_application.shared_ownership).to be_nil
      expect(legal_aid_application.percentage_home).to be_nil
      described_form.save!
      expect(legal_aid_application.property_value).to eq 10_000
      expect(legal_aid_application.outstanding_mortgage_amount).to eq 20
      expect(legal_aid_application.shared_ownership).to eq "friend_family_member_or_other_individual"
      expect(legal_aid_application.percentage_home).to eq 85
    end
  end
end
