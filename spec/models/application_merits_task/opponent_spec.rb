require "rails_helper"

module ApplicationMeritsTask
  RSpec.describe Opponent do
    describe "Individual" do
      subject(:opponent) { build(:opponent, :for_individual) }

      it { expect(opponent.opposable.ccms_relationship_to_case).to eq "OPP" }
      it { expect(opponent.opposable.ccms_child?).to be false }
      it { expect(opponent.opposable.ccms_opponent_relationship_to_case).to eq "Opponent" }
      it { expect(opponent.opposable).to respond_to(:first_name, :last_name) }
    end

    describe "CCMSOpponentIdGenerator concern" do
      let(:expected_id) { Faker::Number.number(digits: 8) }

      context "when ccms_opponent_id is nil" do
        before { expect(CCMS::OpponentId).to receive(:next_serial_id).and_return(expected_id) }

        let(:opponent) { create(:opponent, ccms_opponent_id: nil) }

        it "returns the next serial id" do
          expect(opponent.generate_ccms_opponent_id).to eq expected_id
        end

        it "updates the ccms_opponent_id on the record" do
          opponent.generate_ccms_opponent_id
          expect(opponent.reload.ccms_opponent_id).to eq expected_id
        end
      end

      context "when ccms_opponent_id is already populated" do
        before { expect(CCMS::OpponentId).not_to receive(:next_serial_id) }

        let(:opponent) { create(:opponent, ccms_opponent_id: 1234) }

        it "returns the value" do
          expect(opponent.generate_ccms_opponent_id).to eq 1234
        end

        it "does not update the record with a different value" do
          opponent.generate_ccms_opponent_id
          expect(opponent.reload.ccms_opponent_id).to eq 1234
        end
      end
    end
  end
end
