require "rails_helper"

RSpec.describe LegalFramework::ProceedingTypes::All do
  subject(:all) { described_class }

  before do
    allow(Setting).to receive(:special_childrens_act?).and_return(sca_enabled)
    stub_request(:get, uri).to_return(body: all_proceeding_types_payload)
  end

  let(:uri) { "#{Rails.configuration.x.legal_framework_api_host}/proceeding_types/all" }

  describe ".call" do
    subject(:call) { all.call(provider:) }

    before { call }

    let(:provider) { create(:provider) }

    context "when the special children act setting is on" do
      let(:sca_enabled) { true }

      it "returns all the proceedings" do
        expect(call.map(&:ccms_code)).to match_array %w[DA001 SE097 DA003 SE016E DA006 PB003]
      end
    end

    context "when the special children act setting is off" do
      let(:sca_enabled) { false }

      it "returns all the proceedings" do
        expect(call.map(&:ccms_code)).to match_array %w[DA001 SE097 DA003 SE016E DA006]
      end
    end
  end

  def all_proceeding_types_payload
    [
      {
        ccms_code: "DA001",
        meaning: "Inherent jurisdiction high court injunction",
        description: "to be represented on an application for an injunction, order or declaration under the inherent jurisdiction of the court.",
        full_s8_only: false,
        sca_core: false,
        sca_related: false,
        ccms_category_law: "Family",
        ccms_matter_code: "MINJN",
        ccms_matter: "Domestic abuse",
      },
      {
        ccms_code: "SE097",
        meaning: "Reloacation enforcement",
        description: "to be represented on an application for the revocation of an enforcement order under section 11J and Schedule A1 Children Act 1989.",
        full_s8_only: true,
        sca_core: false,
        sca_related: false,
        ccms_category_law: "Family",
        ccms_matter_code: "KSEC8",
        ccms_matter: "Children - section 8",
      },
      {
        ccms_code: "DA003",
        meaning: "Harassment - injunction",
        description: "to be represented in an action for an injunction under section 3 Protection from Harassment Act 1997.",
        full_s8_only: false,
        sca_core: false,
        sca_related: false,
        ccms_category_law: "Family",
        ccms_matter_code: "MINJN",
        ccms_matter: "Domestic abuse",
      },
      {
        ccms_code: "SE016E",
        meaning: "Vary CAO residence-Enforcement",
        description: "to be represented on an application to vary or discharge a child arrangements order –where the child(ren) will live. Enforcement only.",
        full_s8_only: true,
        sca_core: false,
        sca_related: false,
        ccms_category_law: "Family",
        ccms_matter_code: "KSEC8",
        ccms_matter: "Children - section 8",
      },
      {
        ccms_code: "DA006",
        meaning: "Extend, variation or discharge - Part IV",
        description: "to be represented on an application to extend, vary or discharge an order under Part IV Family Law Act 1996",
        full_s8_only: false,
        sca_core: false,
        sca_related: false,
        ccms_category_law: "Family",
        ccms_matter_code: "MINJN",
        ccms_matter: "Domestic abuse",
      },
      {
        ccms_code: "PB003",
        meaning: "Child assessment order",
        description: "to be represented on an application for a child assessment order.",
        full_s8_only: false,
        sca_core: true,
        sca_related: false,
        ccms_category_law: "Family",
        ccms_matter_code: "KPBLW",
        ccms_matter: "Special Children Act",
      },
    ].to_json
  end
end
