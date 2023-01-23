require "rails_helper"

RSpec.describe TranslatableModelAttribute do
  let(:record) { create(:legal_aid_application) }

  describe "#enum_t" do
    context "when translation exists" do
      it "translates" do
        expect(record.state).to eq "initiated"
        expect(record.enum_t(:state)).to eq "In progress"
      end
    end

    context "when translation does not exist" do
      it "returns translation not found message" do
        allow(record).to receive(:state).and_return("unknown_state")
        expect(record.enum_t(:state)).to eq "translation missing: en.model_enum_translations.legal_aid_application.state.unknown_state"
      end
    end
  end
end
