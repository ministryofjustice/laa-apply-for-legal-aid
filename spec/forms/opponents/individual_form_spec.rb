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
        expect(name_form).to be_invalid
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
        expect(name_form).to be_invalid
        expect(name_form.errors.messages).to include(:last_name)
      end
    end
  end

  describe "#save" do
    subject(:save_form) { name_form.save }

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
end
