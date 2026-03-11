require "rails_helper"

module ApplicationMeritsTask
  RSpec.describe InvolvedChild do
    describe "standard values" do
      subject(:involved_child) { build(:involved_child) }

      it { expect(involved_child.ccms_other_party_type).to eq "PERSON" }
      it { expect(involved_child.ccms_relationship_to_case).to eq "CHILD" }
      it { expect(involved_child.ccms_relationship_to_client).to eq "UNKNOWN" }
      it { expect(involved_child.ccms_child?).to be true }
      it { expect(involved_child.ccms_opponent_relationship_to_case).to eq "Child" }
    end

    describe "CCMSOpponentIdGenerator concern" do
      let(:expected_id) { Faker::Number.number(digits: 8) }

      context "when ccms_opponent_id is nil" do
        before { allow(CCMS::OpponentId).to receive(:next_serial_id).and_return(expected_id) }

        let(:involved_child) { create(:involved_child, first_name: "John", last_name: "Doe", ccms_opponent_id: nil) }

        it "returns the next serial id" do
          expect(involved_child.generate_ccms_opponent_id).to eq expected_id
        end

        it "updates the ccms_opponent_id on the record" do
          involved_child.generate_ccms_opponent_id
          expect(involved_child.reload.ccms_opponent_id).to eq expected_id
        end
      end

      context "when ccms_opponent_id is already populated" do
        let(:involved_child) { create(:involved_child, first_name: "John", last_name: "Doe", ccms_opponent_id: 4553) }

        it "returns the value" do
          expect(CCMS::OpponentId).not_to receive(:next_serial_id)
          expect(involved_child.generate_ccms_opponent_id).to eq 4553
        end

        it "does not update the record with a different value" do
          expect(CCMS::OpponentId).not_to receive(:next_serial_id)
          involved_child.generate_ccms_opponent_id
          expect(involved_child.reload.ccms_opponent_id).to eq 4553
        end
      end
    end
  end
end
