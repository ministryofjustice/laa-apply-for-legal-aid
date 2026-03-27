require "rails_helper"

RSpec.describe ProceedingJsonBuilder do
  subject(:json) { described_class.build(proceeding).as_json }

  let(:proceeding) { create(:proceeding, :special_children_act) }

  it "includes the expected keys" do
    expect(json.keys).to include(
      :id,
      :legal_aid_application_id,
      :proceeding_case_id,
      :lead_proceeding,
      :ccms_code,
      :meaning,
      :description,
      :substantive_cost_limitation,
      :delegated_functions_cost_limitation,
      :used_delegated_functions_on,
      :used_delegated_functions_reported_on,
      :created_at,
      :updated_at,
      :name,
      :matter_type,
      :category_of_law,
      :category_law_code,
      :ccms_matter_code,
      :client_involvement_type_ccms_code,
      :client_involvement_type_description,
      :used_delegated_functions,
      :emergency_level_of_service,
      :emergency_level_of_service_name,
      :emergency_level_of_service_stage,
      :substantive_level_of_service,
      :substantive_level_of_service_name,
      :substantive_level_of_service_stage,
      :accepted_emergency_defaults,
      :accepted_substantive_defaults,
      :sca_type,
      :related_orders,

      # nested relations below this line
      :scope_limitations,
      :final_hearings,

      # transformed data below this line
      :category_of_law_enum,
      :matter_type_enum,
    )
  end

  context "when the proceeding is a special children act matter type" do
    let(:proceeding) { create(:proceeding, :special_children_act) }

    it "maps the category_of_law to FAMILY" do
      expect(json[:category_of_law_enum]).to eq("FAMILY")
    end

    it "maps the matter_type to SPECIAL_CHILDREN_ACT" do
      expect(json[:matter_type_enum]).to eq("SPECIAL_CHILDREN_ACT")
    end
  end

  context "when the proceeding is a public law family matter type" do
    let(:proceeding) { create(:proceeding, :public_law_family) }

    it "maps the category_of_law to FAMILY" do
      expect(json[:category_of_law_enum]).to eq("FAMILY")
    end

    it "maps the matter_type to PUBLIC_LAW_FAMILY" do
      expect(json[:matter_type_enum]).to eq("PUBLIC_LAW_FAMILY")
    end
  end

  context "when the proceeding is a section 8 children matter type" do
    let(:proceeding) { create(:proceeding, :section_8_children) }

    it "maps the category_of_law to FAMILY" do
      expect(json[:category_of_law_enum]).to eq("FAMILY")
    end

    it "maps the matter_type to SECTION_8_CHILDREN" do
      expect(json[:matter_type_enum]).to eq("SECTION_8_CHILDREN")
    end
  end

  context "when the proceeding is a domestic abuse matter type" do
    let(:proceeding) { create(:proceeding, :domestic_abuse) }

    it "maps the category_of_law to FAMILY" do
      expect(json[:category_of_law_enum]).to eq("FAMILY")
    end

    it "maps the matter_type to DOMESTIC_ABUSE" do
      expect(json[:matter_type_enum]).to eq("DOMESTIC_ABUSE")
    end
  end

  # NOTE: should not be possible going forward but there is historical data that does not match current expected string matter types
  context "when the proceeding is an unknown matter type" do
    let(:proceeding) { create(:proceeding, :domestic_abuse, matter_type: "Unknown Matter Type (UMT)") }

    it "maps the category_of_law to FAMILY" do
      expect(json[:category_of_law_enum]).to eq("FAMILY")
    end

    it "maps the matter_type to a normalized version of the original string, removing parenthetical content" do
      expect(json[:matter_type_enum]).to eq("UNKNOWN_MATTER_TYPE")
    end
  end

  # NOTE: should not be possible, but will not break the payload builder
  context "when the proceeding has a blank matter type" do
    let(:proceeding) { create(:proceeding, :domestic_abuse, matter_type: "") }

    it "maps the matter_type to nil" do
      expect(json[:matter_type_enum]).to eq("")
    end
  end
end
