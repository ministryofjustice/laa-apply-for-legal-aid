require "rails_helper"

RSpec.describe Opponents::IndividualForm, type: :form do
  subject(:name_form) { described_class.new(form_params) }

  let(:form_params) do
    {
      "first_name" => "Bob",
      "last_name" => "Smith",
      "legal_aid_application" => legal_aid_application,
      "model" => opponent,
    }
  end

  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:opponent) { ApplicationMeritsTask::Opponent.new }

  describe "validation" do
    subject(:valid_form) { name_form.valid? }

    it "when the params are complete" do
      expect(valid_form).to be true
    end

    context "when the name is incomplete" do
      let(:form_params) do
        {
          "first_name" => "",
          "last_name" => "Smith",
          "legal_aid_application" => legal_aid_application,
          "model" => opponent,
        }
      end

      it "has first name error" do
        expect(name_form).not_to be_valid
        expect(name_form.errors.messages).to include(:first_name)
      end
    end

    context "when the last name is incomplete" do
      let(:form_params) do
        {
          "first_name" => "Bob",
          "legal_aid_application" => legal_aid_application,
          "model" => opponent,
        }
      end

      it "has last name error" do
        expect(name_form).not_to be_valid
        expect(name_form.errors.messages).to include(:last_name)
      end
    end
  end

  describe "#save" do
    subject(:save_form) { name_form.save }

    context "with no existing opposable object" do
      it "creates a new individual" do
        expect { save_form }.to change(ApplicationMeritsTask::Individual, :count).by(1)

        expect(name_form.model).to have_attributes(
          first_name: "Bob",
          last_name: "Smith",
        )
      end

      it "creates and associates a new opponent with the individual" do
        expect { save_form }.to change(ApplicationMeritsTask::Opponent, :count).by(1)
        expect(opponent.opposable).to be_present
      end
    end

    context "with existing opposable object" do
      let!(:opponent) { create(:opponent, :for_individual, first_name: "Milly", last_name: "Bob") }

      let(:form_params) do
        {
          "first_name" => "Billy",
          "last_name" => "Bobs",
          "legal_aid_application" => legal_aid_application,
          "model" => opponent,
        }
      end

      it "updates the existing individual" do
        expect { save_form }
          .to change(opponent.opposable, :first_name).from("Milly").to("Billy")
          .and change(opponent.opposable, :last_name).from("Bob").to("Bobs")
      end

      it "does not add an individual" do
        expect { save_form }.not_to change(ApplicationMeritsTask::Opponent, :count)
      end
    end
  end
end
