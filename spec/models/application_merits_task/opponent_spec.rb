require "rails_helper"

module ApplicationMeritsTask
  RSpec.describe Opponent do
    context "with an Individual" do
      subject(:opponent) { build(:opponent, :for_individual) }

      it { expect(opponent.ccms_relationship_to_case).to eq "OPP" }
      it { expect(opponent.ccms_child?).to be false }
      it { expect(opponent.ccms_opponent_relationship_to_case).to eq "Opponent" }
      it { expect(opponent).to respond_to(:first_name, :last_name, :full_name) }

      describe "#belongs_to" do
        before { opponent.save! }

        it "belongs to an opposable Individual" do
          expect(opponent).to respond_to(:opposable)
          expect(opponent.opposable).to be_an(ApplicationMeritsTask::Individual)
        end
      end

      describe "#destroy!" do
        before { opponent.save! }

        it "removes the opposable Individual" do
          expect { opponent.destroy }
            .to change(ApplicationMeritsTask::Individual, :count).by(-1)
        end
      end
    end

    describe "#generate_ccms_opponent_id" do
      context "when #ccms_opponent_id is nil" do
        before { allow(CCMS::OpponentId).to receive(:next_serial_id).and_return(9999) }

        let(:opponent) { create(:opponent, ccms_opponent_id: nil) }

        it "generates a new opponent Id" do
          opponent.generate_ccms_opponent_id
          expect(CCMS::OpponentId).to have_received(:next_serial_id)
        end

        it "returns the next serial opponent id" do
          expect(opponent.generate_ccms_opponent_id).to be(9999)
        end

        it "updates the ccms_opponent_id on the record" do
          expect { opponent.generate_ccms_opponent_id }
            .to change { opponent.reload.ccms_opponent_id }
              .from(nil)
              .to(9999)
        end
      end

      context "when #ccms_opponent_id is already populated" do
        before { allow(CCMS::OpponentId).to receive(:next_serial_id).and_call_original }

        let(:opponent) { create(:opponent, ccms_opponent_id: 1234) }

        it "does not generate a new opponent Id" do
          opponent.generate_ccms_opponent_id
          expect(CCMS::OpponentId).not_to have_received(:next_serial_id)
        end

        it "returns the existing value" do
          expect(opponent.generate_ccms_opponent_id).to eq 1234
        end

        it "does not update the ccms_opponent_id on the record" do
          expect { opponent.generate_ccms_opponent_id }
            .not_to change { opponent.reload.ccms_opponent_id }
              .from(1234)
        end
      end
    end
  end
end
