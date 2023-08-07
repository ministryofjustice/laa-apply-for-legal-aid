require "rails_helper"

RSpec.describe Opponents::OrganisationForm, :vcr, type: :form do
  subject(:organisation_form) { described_class.new(form_params) }

  let(:form_params) do
    {
      "name" => "Central Beds Council",
      "organisation_type_ccms_code" => "LA",
      "legal_aid_application" => legal_aid_application,
      "model" => opponent,
    }
  end

  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:opponent) { ApplicationMeritsTask::Opponent.new }

  describe "validation" do
    subject(:valid_form) { organisation_form.valid? }

    it "when the params are complete" do
      expect(valid_form).to be true
    end

    context "when the name is incomplete" do
      let(:form_params) do
        {
          "name" => "",
          "organisation_type_ccms_code" => "LA",
          "legal_aid_application" => legal_aid_application,
          "model" => opponent,
        }
      end

      it "has name error" do
        expect(organisation_form).to be_invalid
        expect(organisation_form.errors.messages).to include(:name)
      end
    end

    context "when the type is incomplete" do
      let(:form_params) do
        {
          "name" => "Central Beds Council",
          "organisation_type_ccms_code" => "",
          "legal_aid_application" => legal_aid_application,
          "model" => opponent,
        }
      end

      it "has type error" do
        expect(organisation_form).to be_invalid
        expect(organisation_form.errors.messages).to include(:organisation_type_ccms_code)
      end
    end
  end

  describe "#save" do
    subject(:save_form) { organisation_form.save }

    context "with no existing opposable object" do
      it "creates a new organisation" do
        expect { save_form }.to change(ApplicationMeritsTask::Organisation, :count).by(1)

        expect(organisation_form.model).to have_attributes(
          name: "Central Beds Council",
          ccms_code: "LA",
          description: "Local Authority",
        )
      end

      it "creates and associates a new opponent with the organisation" do
        expect { save_form }.to change(ApplicationMeritsTask::Opponent, :count).by(1)
        expect(opponent.opposable).to be_present
      end
    end

    context "with existing opposable object" do
      let!(:opponent) { create(:opponent, :for_organisation, organisation_name: "Bucks Council", organisation_ccms_code: "LA", organisation_description: "Local Authority") }

      it "updates the existing organisation" do
        expect { save_form }
          .to change(opponent.opposable, :name).from("Bucks Council").to("Central Beds Council")
      end

      it "does not add an organisation" do
        expect { save_form }.not_to change(ApplicationMeritsTask::Opponent, :count)
      end
    end
  end
end
