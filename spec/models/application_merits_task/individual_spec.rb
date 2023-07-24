require "rails_helper"

module ApplicationMeritsTask
  RSpec.describe Individual do
    subject(:individual) { build(:individual) }

    it { expect(individual.ccms_relationship_to_case).to eq "OPP" }
    it { expect(individual.ccms_child?).to be false }
    it { expect(individual.ccms_opponent_relationship_to_case).to eq "Opponent" }
    it { expect(individual).to respond_to(:first_name, :last_name, :full_name) }

    context "with an opponent" do
      let(:individual) { opponent.opposable }

      describe "#generate_ccms_opponent_id" do
        context "when #ccms_opponent_id is nil" do
          before { allow(CCMS::OpponentId).to receive(:next_serial_id).and_return(9999) }

          let(:opponent) { create(:opponent, :for_individual, ccms_opponent_id: nil) }

          it "generates a new opponent Id" do
            individual.generate_ccms_opponent_id
            expect(CCMS::OpponentId).to have_received(:next_serial_id)
          end

          it "returns the next serial opponent id" do
            expect(individual.generate_ccms_opponent_id).to be(9999)
          end

          it "updates the ccms_opponent_id on the record" do
            expect { individual.generate_ccms_opponent_id }
              .to change { individual.reload.ccms_opponent_id }
                .from(nil)
                .to(9999)
          end
        end

        context "when #ccms_opponent_id is already populated" do
          before { allow(CCMS::OpponentId).to receive(:next_serial_id).and_call_original }

          let(:opponent) { create(:opponent, :for_individual, ccms_opponent_id: 1234) }

          it "does not generate a new opponent Id" do
            individual.generate_ccms_opponent_id
            expect(CCMS::OpponentId).not_to have_received(:next_serial_id)
          end

          it "returns the existing value" do
            expect(individual.generate_ccms_opponent_id).to eq 1234
          end

          it "does not update the ccms_opponent_id on the record" do
            expect { individual.generate_ccms_opponent_id }
              .not_to change { individual.reload.ccms_opponent_id }
                .from(1234)
          end
        end
      end
    end
  end
end
