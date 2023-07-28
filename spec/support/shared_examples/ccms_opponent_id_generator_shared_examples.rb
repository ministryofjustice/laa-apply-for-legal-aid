RSpec.shared_examples "CCMS opponent id generator" do
  describe "#generate_ccms_opponent_id" do
    let(:opposable) { opponent.opposable }

    context "when #ccms_opponent_id is nil" do
      before do
        opponent.update!(ccms_opponent_id: nil)
        allow(CCMS::OpponentId).to receive(:next_serial_id).and_return(9999)
      end

      it "generates a new opponent Id" do
        opposable.generate_ccms_opponent_id
        expect(CCMS::OpponentId).to have_received(:next_serial_id)
      end

      it "returns the next serial opponent id" do
        expect(opposable.generate_ccms_opponent_id).to be(9999)
      end

      it "updates the ccms_opponent_id on the record" do
        expect { opposable.generate_ccms_opponent_id }
          .to change { opposable.reload.ccms_opponent_id }
            .from(nil)
            .to(9999)
      end
    end

    context "when #ccms_opponent_id is already populated" do
      before do
        opponent.update!(ccms_opponent_id: 1234)
        allow(CCMS::OpponentId).to receive(:next_serial_id).and_call_original
      end

      it "does not generate a new opponent Id" do
        opposable.generate_ccms_opponent_id
        expect(CCMS::OpponentId).not_to have_received(:next_serial_id)
      end

      it "returns the existing value" do
        expect(opposable.generate_ccms_opponent_id).to eq 1234
      end

      it "does not update the ccms_opponent_id on the record" do
        expect { opposable.generate_ccms_opponent_id }
          .not_to change { opposable.reload.ccms_opponent_id }
            .from(1234)
      end
    end
  end
end
