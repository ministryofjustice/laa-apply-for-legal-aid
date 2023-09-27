require "rails_helper"

module LegalFramework
  RSpec.describe AddOpponentOrganisationService, :vcr do
    subject(:instance) { described_class.new(legal_aid_application) }

    let(:legal_aid_application) { create(:legal_aid_application) }

    describe "#call" do
      context "with a duck" do
        let(:duck_type) do
          Struct.new(:name, :ccms_opponent_id, :ccms_type_code, :ccms_type_text)
        end

        let(:duck_object) do
          duck_type.new("Foobar Council", "222222", "LA", "Local Authority")
        end

        it "adds an opponent" do
          expect { instance.call(duck_object) }.to change { legal_aid_application.opponents.count }.by(1)
        end

        it "adds an organisation" do
          expect { instance.call(duck_object) }.to change { legal_aid_application.opponents.organisations.count }.by(1)
        end

        it "adds an opponent and organisation with the appropriate attributes" do
          instance.call(duck_object)
          opponent = legal_aid_application.opponents.first

          expect(opponent.opposable)
            .to have_attributes(name: "Foobar Council",
                                ccms_type_code: "LA",
                                ccms_type_text: "Local Authority")

          expect(opponent)
            .to have_attributes(ccms_opponent_id: 222_222,
                                exists_in_ccms: true,
                                opposable_type: "ApplicationMeritsTask::Organisation",
                                opposable_id: opponent.opposable.id)
        end
      end

      context "without a duck" do
        let(:not_a_duck) { {} }

        it "raises error" do
          expect { instance.call(not_a_duck) }.to raise_error NoMethodError
        end
      end
    end
  end
end
