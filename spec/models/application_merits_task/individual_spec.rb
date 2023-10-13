require "rails_helper"

module ApplicationMeritsTask
  RSpec.describe Individual do
    subject(:individual) { build(:individual) }

    it { expect(individual.ccms_other_party_type).to eq "PERSON" }
    it { expect(individual.ccms_relationship_to_case).to eq "OPP" }
    it { expect(individual.ccms_relationship_to_client).to eq "NONE" }
    it { expect(individual.ccms_child?).to be false }
    it { expect(individual.ccms_opponent_relationship_to_case).to eq "Opponent" }
    it { expect(individual).to respond_to(:first_name, :last_name, :full_name) }

    context "with an opponent" do
      let(:opponent) { create(:opponent, :for_individual) }

      it_behaves_like "CCMS opponent id generator"

      describe "#has_one" do
        let(:individual) { opponent.opposable }

        it "has an #opponent" do
          expect(individual).to respond_to(:opponent)
          expect(individual.opponent).to eql(opponent)
        end
      end

      describe "#destroy!" do
        before { individual }

        let(:individual) { opponent.opposable }

        it "removes the opponent" do
          expect { individual.destroy! }
            .to change(ApplicationMeritsTask::Opponent, :count).by(-1)
        end
      end
    end
  end
end
