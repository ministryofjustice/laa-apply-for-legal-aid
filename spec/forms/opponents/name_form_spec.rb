require "rails_helper"

RSpec.describe Opponents::NameForm, type: :form do
  subject(:name_form) { described_class.new(form_params) }

  let(:params) do
    {
      "first_name" => "Bob",
      "last_name" => "Smith",
    }
  end
  let(:opponent) { create(:individual_opponent) }
  let(:form_params) { params.merge(model: opponent) }

  describe "validation" do
    subject(:valid_form) { name_form.valid? }

    it "when the params are complete" do
      expect(valid_form).to be true
    end

    context "when the name is incomplete" do
      let(:params) do
        {
          "first_name" => "",
          "last_name" => "Smith",
        }
      end

      it { is_expected.to be false }
    end
  end

  describe "#save" do
    subject(:save_form) { name_form.save }

    it "creates a new opponent" do
      save_form
      expect(opponent).to have_attributes(
        first_name: "Bob",
        last_name: "Smith",
      )
    end
  end
end
