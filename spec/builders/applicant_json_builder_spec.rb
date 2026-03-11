require "rails_helper"
RSpec.describe ApplicantJsonBuilder do
  describe "#as_json" do
    subject(:json) { described_class.build(applicant).as_json }

    let(:applicant) { create(:applicant, relationship_to_children: "foobar") }

    it "includes relationship_to_involved_children as uppercase version of relationship_to_children" do
      expect(json[:relationship_to_involved_children]).to eq("FOOBAR")
    end

    context "when relationship_to_children is nil" do
      let(:applicant) { create(:applicant, relationship_to_children: nil) }

      it "returns nil for relationship_to_involved_children" do
        expect(json[:relationship_to_involved_children]).to be_nil
      end
    end
  end
end
