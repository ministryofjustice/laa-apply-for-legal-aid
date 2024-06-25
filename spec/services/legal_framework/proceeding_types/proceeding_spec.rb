require "rails_helper"

RSpec.describe LegalFramework::ProceedingTypes::Proceeding, :vcr do
  subject(:proceeding) { described_class }

  let(:ccms_code) { "DA004" }
  let(:uri) { "#{Rails.configuration.x.legal_framework_api_host}/proceeding_types/#{ccms_code}" }

  describe ".call" do
    subject(:call) { proceeding.call(ccms_code) }

    before { call }

    it "makes one external call" do
      expect(a_request(:get, uri)).to have_been_made.times(1)
    end

    it "returns the expected object" do
      expect(call).to be_instance_of(LegalFramework::ProceedingTypes::Proceeding::Response)
    end

    it "returns a success status" do
      expect(call.success).to be true
    end

    it "returns details of the correct proceeding" do
      expect(call.ccms_code).to eq ccms_code
    end

    it "has the expected values in all attributes" do
      response = call
      expect(response.ccms_category_law).to eq "Family"
      expect(response.ccms_category_law_code).to eq "MAT"
      expect(response.ccms_matter).to eq "Domestic abuse"
      expect(response.ccms_matter_code).to eq "MINJN"
      expect(response.cost_limitations).to eq expected_cost_limitations
      expect(response.default_scope_limitations).to eq expected_default_scope_limitations
      expect(response.description).to eq "to be represented on an application for a non-molestation order."
      expect(response.meaning).to eq "Non-molestation order"
      expect(response.sca_type).to be_nil
    end

    context "when the proceeding is core sca" do
      let(:ccms_code) { "PB003" }

      it "has the expected values in all attributes" do
        response = call
        expect(response.meaning).to eq "Child assessment order"
        expect(response.sca_type).to eq "core"
      end
    end

    context "when the proceeding is related sca" do
      let(:ccms_code) { "PB007" }

      it "has the expected values in all attributes" do
        response = call
        expect(response.meaning).to eq "Contact with a child in care"
        expect(response.sca_type).to eq "related"
      end
    end

    def expected_cost_limitations
      {
        "substantive" => {
          "start_date" => "1970-01-01",
          "value" => "25000.0",
        },
        "delegated_functions" => {
          "start_date" => "2021-09-13",
          "value" => "2250.0",
        },
      }
    end

    def expected_default_scope_limitations
      {
        "substantive" => {
          "code" => "AA019",
          "meaning" => "Injunction FLA-to final hearing",
          "description" => substantive_description.chomp,
        },
        "delegated_functions" => {
          "code" => "CV117",
          "meaning" => "Interim order inc. return date",
          "description" => "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
        },
      }
    end

    def substantive_description
      text = <<~END_OF_TEXT
        As to proceedings under Part IV Family Law Act 1996 limited to all steps
        up to and including obtaining and serving a final order and in the event of breach
        leading to the exercise of a power of arrest to representation on the consideration
        of the breach by the court (but excluding applying for a warrant of arrest,
        if not attached, and representation in contempt proceedings).
      END_OF_TEXT

      text.chomp.tr("\n", " ")
    end
  end
end
