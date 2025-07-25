require "rails_helper"

RSpec.describe LegalFramework::ProceedingTypes::All do
  subject(:all) { described_class.new(legal_aid_application) }

  before do
    stub_request(:post, uri).to_return(body:)
  end

  let(:legal_aid_application) { create :legal_aid_application }
  let(:body) { all_proceeding_types_payload }
  let(:uri) { "#{Rails.configuration.x.legal_framework_api_host}/proceeding_types/filter" }

  describe ".call" do
    subject(:call) { all.call }

    context "when all proceedings returned" do
      it "returns the expected proceedings array" do
        expect(call.map(&:ccms_code)).to match_array %w[DA001 SE097 DA003 SE016E DA006 PB003 PBM01]
      end
    end

    context "when the requested application returns no proceedings" do
      let(:body) { no_proceedings_returned }

      it "returns an empty array" do
        expect(call.map(&:ccms_code)).to eql []
      end
    end
  end

  def all_proceeding_types_payload
    {
      success: true,
      data: [
        {
          ccms_code: "DA001",
          meaning: "Inherent jurisdiction high court injunction",
          description: "to be represented on an application for an injunction, order or declaration under the inherent jurisdiction of the court.",
          sca_core: false,
          sca_related: false,
          ccms_category_law: "Family",
          ccms_category_law_code: "MAT",
          ccms_matter_code: "MINJN",
          ccms_matter: "domestic abuse (DA)",
        },
        {
          ccms_code: "SE097",
          meaning: "Reloacation enforcement",
          description: "to be represented on an application for the revocation of an enforcement order under section 11J and Schedule A1 Children Act 1989.",
          sca_core: false,
          sca_related: false,
          ccms_category_law: "Family",
          ccms_category_law_code: "MAT",
          ccms_matter_code: "KSEC8",
          ccms_matter: "section 8 children (S8)",
        },
        {
          ccms_code: "DA003",
          meaning: "Harassment - injunction",
          description: "to be represented in an action for an injunction under section 3 Protection from Harassment Act 1997.",
          sca_core: false,
          sca_related: false,
          ccms_category_law: "Family",
          ccms_category_law_code: "MAT",
          ccms_matter_code: "MINJN",
          ccms_matter: "domestic abuse (DA)",
        },
        {
          ccms_code: "SE016E",
          meaning: "Vary CAO residence-Enforcement",
          description: "to be represented on an application to vary or discharge a child arrangements order –where the child(ren) will live. Enforcement only.",
          sca_core: false,
          sca_related: false,
          ccms_category_law: "Family",
          ccms_category_law_code: "MAT",
          ccms_matter_code: "KSEC8",
          ccms_matter: "section 8 children (S8)",
        },
        {
          ccms_code: "DA006",
          meaning: "Extend, variation or discharge - Part IV",
          description: "to be represented on an application to extend, vary or discharge an order under Part IV Family Law Act 1996",
          sca_core: false,
          sca_related: false,
          ccms_category_law: "Family",
          ccms_category_law_code: "MAT",
          ccms_matter_code: "MINJN",
          ccms_matter: "domestic abuse (DA)",
        },
        {
          ccms_code: "PB003",
          meaning: "Child assessment order",
          description: "to be represented on an application for a child assessment order.",
          sca_core: true,
          sca_related: false,
          ccms_category_law: "Family",
          ccms_category_law_code: "MAT",
          ccms_matter_code: "KPBLW",
          ccms_matter: "special children act (SCA)",
        },
        {
          ccms_code: "PBM01",
          meaning: "Declaration for overseas adoption-Pub Law-Fam",
          description: "to be updated when the actual value is known!",
          sca_core: false,
          sca_related: false,
          ccms_category_law: "Family",
          ccms_category_law_code: "MAT",
          ccms_matter_code: "KPBLB",
          ccms_matter: "public law family (PLF)",
        },
      ],
    }.to_json
  end

  def no_proceedings_returned
    { "success" => false, "data" => [] }.to_json
  end
end
