require "rails_helper"

RSpec.describe LinkedApplication do
  subject(:linked_application) do
    build(:linked_application,
          lead_application: laa_lead,
          associated_application: laa_associated,
          target_application: laa_target,
          link_type_code: link_type_text)
  end

  let(:laa_lead) { build(:legal_aid_application) }
  let(:laa_associated) { build(:legal_aid_application) }
  let(:laa_target) { build(:legal_aid_application) }
  let(:link_type_text) { "FC_LEAD" }

  describe "#lead_application" do
    subject(:lead_application) { linked_application.lead_application }

    it { expect(lead_application).to be_instance_of(LegalAidApplication) }
    it { expect(lead_application).to eq laa_lead }
  end

  describe "#associated_application" do
    subject(:associated_application) { linked_application.associated_application }

    it { expect(associated_application).to be_instance_of(LegalAidApplication) }
    it { expect(associated_application).to eq laa_associated }
  end

  describe "#target_application" do
    subject(:target_application) { linked_application.target_application }

    it { expect(target_application).to be_instance_of(LegalAidApplication) }
    it { expect(target_application).to eq laa_target }
  end

  describe "#link_type_code" do
    subject(:link_type_code) { linked_application.link_type_code }

    it { expect(link_type_code).to eq "FC_LEAD" }
  end

  describe "#link_type_description" do
    subject(:link_type_code) { linked_application.link_type_description }

    it { expect(link_type_code).to eq "Family" }
  end

  context "when validating" do
    before { linked_application.validate }

    context "with valid linked_application" do
      it { is_expected.to be_valid }
    end

    context "with invalid link_type_code" do
      let(:link_type_text) { "FOOBAR" }

      it { is_expected.not_to be_valid }
    end

    context "with identical lead and associated applications" do
      let(:laa_lead) { laa_associated }
      let(:laa_associated) { build(:legal_aid_application) }

      it { is_expected.not_to be_valid }
      it { expect(linked_application.errors.messages.values.flatten).to include("Application cannot be linked to itself") }
    end
  end
end
