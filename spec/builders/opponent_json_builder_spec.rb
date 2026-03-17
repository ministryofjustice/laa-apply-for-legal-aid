require "rails_helper"

RSpec.describe OpponentJsonBuilder do
  subject(:json) { described_class.build(opponent).as_json }

  let(:opponent) { create(:opponent) }

  it "includes the expected keys" do
    expect(json.keys).to include(
      :id,
      :legal_aid_application_id,
      :created_at,
      :updated_at,
      :ccms_opponent_id,
      :opposable_type,
      :opposable_id,
      :exists_in_ccms,
      :opposable,

      # Mappings used by Datastore/Decide
      :opponent_type,
      :first_name,
      :last_name,
      :organisation_name,
    )
  end

  context "when the opponent is an individual" do
    let(:opponent) { create(:opponent, :for_individual, first_name: "John", last_name: "Doe") }

    it "maps the opponent_type to INDIVIDUAL" do
      expect(json[:opponent_type]).to eq("INDIVIDUAL")
    end

    it "includes the individual's first and last name" do
      expect(json[:first_name]).to eq("John")
      expect(json[:last_name]).to eq("Doe")
    end

    it "includes an organisation_name of nil" do
      expect(json[:organisation_name]).to be_nil
    end

    it "includes an opposable object with the expected keys" do
      expect(json[:opposable].keys).to include(
        :id,
        :created_at,
        :updated_at,
        :first_name,
        :last_name,
      )
    end
  end

  context "when the opponent is an organisation" do
    let(:opponent) { create(:opponent, :for_organisation, organisation_name: "Acme Corp") }

    it "maps the opponent_type to ORGANISATION" do
      expect(json[:opponent_type]).to eq("ORGANISATION")
    end

    it "includes the organisation's name" do
      expect(json[:organisation_name]).to eq("Acme Corp")
    end

    it "includes an individual's first and last name of nil" do
      expect(json[:first_name]).to be_nil
      expect(json[:last_name]).to be_nil
    end

    it "includes an opposable object with the expected keys" do
      expect(json[:opposable].keys).to include(
        :id,
        :ccms_type_code,
        :ccms_type_text,
        :created_at,
        :name,
        :updated_at,
      )
    end
  end
end
