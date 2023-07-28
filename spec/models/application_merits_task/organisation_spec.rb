require "rails_helper"

module ApplicationMeritsTask
  RSpec.describe Organisation do
    subject(:organisation) { build(:organisation) }

    it { expect(organisation.ccms_relationship_to_case).to eq "OPP" }
    it { expect(organisation.ccms_child?).to be false }
    it { expect(organisation.ccms_opponent_relationship_to_case).to eq "Opponent" }
    it { expect(organisation).to respond_to(:name, :ccms_code, :description) }

    context "with an opponent" do
      context "when assuming organisation \"name\" is new one in CCMS" do
        # see https://dsdmoj.atlassian.net/wiki/spaces/ATPPB/pages/4460773385/Organisation+Opponents
        # for more information on differences between existing org names and the need to create new
        # ones.

        let(:opponent) { create(:opponent, :for_organisation) }

        it_behaves_like "CCMS opponent id generator"
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
