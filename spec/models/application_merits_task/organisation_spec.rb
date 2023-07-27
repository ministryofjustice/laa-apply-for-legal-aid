require "rails_helper"

module ApplicationMeritsTask
  RSpec.describe Organisation do
    subject(:organisation) { build(:organisation) }

    it { expect(organisation.ccms_relationship_to_case).to eq "OPP" }
    it { expect(organisation.ccms_child?).to be false }
    it { expect(organisation.ccms_opponent_relationship_to_case).to eq "Opponent" }
    it { expect(organisation).to respond_to(:name, :ccms_code, :description) }

    describe "#full_name" do
      subject(:full_name) { organisation.full_name }

      it "alias of attribute #name" do
        expect(full_name).to eql(organisation.name)
      end
    end

    context "with an opponent" do
      let(:organisation) { opponent.opposable }

      # need to handle new organisation ID generation but not for existing?
      describe "#generate_ccms_opponent_id", skip: "TODO or remove" do
        context "when #ccms_opponent_id is nil" do
          before { allow(CCMS::OpponentId).to receive(:next_serial_id).and_return(9999) }

          let(:opponent) { create(:opponent, :for_organisation, ccms_opponent_id: nil) }

          it "generates a new opponent Id" do
            organisation.generate_ccms_opponent_id
            expect(CCMS::OpponentId).to have_received(:next_serial_id)
          end

          it "returns the next serial opponent id" do
            expect(organisation.generate_ccms_opponent_id).to be(9999)
          end

          it "updates the ccms_opponent_id on the record" do
            expect { organisation.generate_ccms_opponent_id }
              .to change { organisation.reload.ccms_opponent_id }
                .from(nil)
                .to(9999)
          end
        end

        context "when #ccms_opponent_id is already populated" do
          before { allow(CCMS::OpponentId).to receive(:next_serial_id).and_call_original }

          let(:opponent) { create(:opponent, :for_organisation, ccms_opponent_id: 1234) }

          it "does not generate a new opponent Id" do
            organisation.generate_ccms_opponent_id
            expect(CCMS::OpponentId).not_to have_received(:next_serial_id)
          end

          it "returns the existing value" do
            expect(organisation.generate_ccms_opponent_id).to eq 1234
          end

          it "does not update the ccms_opponent_id on the record" do
            expect { organisation.generate_ccms_opponent_id }
              .not_to change { organisation.reload.ccms_opponent_id }
                .from(1234)
          end
        end
      end

      describe "#has_one" do
        let(:opponent) { create(:opponent, :for_organisation) }
        let(:organisation) { opponent.opposable }

        it "has an #opponent" do
          expect(organisation).to respond_to(:opponent)
          expect(organisation.opponent).to eql(opponent)
        end
      end

      describe "#destroy!" do
        before { organisation }

        let(:opponent) { create(:opponent, :for_organisation) }
        let(:organisation) { opponent.opposable }

        it "removes the opponent" do
          expect { organisation.destroy! }
            .to change(ApplicationMeritsTask::Opponent, :count).by(-1)
        end
      end
    end
  end
end
