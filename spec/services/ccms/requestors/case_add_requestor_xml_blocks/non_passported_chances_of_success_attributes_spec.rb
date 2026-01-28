require "rails_helper"

RSpec.shared_examples "FAM_PROSP_X attribute omitter" do
  it "does not generate any of the attribute chances of success blocks" do
    xml = request_xml

    chances_of_success_attributes.each do |attr_name|
      block = XmlExtractor.call(xml, :proceeding_merits, attr_name)
      expect(block).not_to be_present, "xml block for attribute #{attr_name} found when it should not be!"
    end
  end
end

RSpec.shared_examples "FAMILY_PROSPECTS_OF_SUCCESS attribute omitter" do
  it "does not add any FAMILY_PROSPECTS_OF_SUCCESS attributes" do
    block = XmlExtractor.call(request_xml, :proceeding_merits, "FAMILY_PROSPECTS_OF_SUCCESS")
    expect(block).not_to be_present, "xml block for attribute FAMILY_PROSPECTS_OF_SUCCESS found when it should not be!"
  end
end

module CCMS
  module Requestors
    RSpec.describe NonPassportedCaseAddRequestor, :ccms do
      describe "XML request" do
        subject(:requestor) { described_class.new(submission, {}) }

        let(:request_xml) { requestor.formatted_xml }
        let(:expected_tx_id) { "202011241154290000006983477" }
        let(:address) { create(:address, address_line_one: "10 Foobar Lane", address_line_two: "Bluewater", city: "Ipswich", county: "Essex", postcode: "GH08NY") }
        let(:provider) { create(:provider, username: "saturnina", firm:, email: "patrick_rath@example.net") }
        let(:firm) { create(:firm, ccms_id: 169) }
        let(:office) { create(:office, ccms_id: "4727432767") }
        let(:submission) { create(:submission, :case_ref_obtained, case_ccms_reference: "300000000001", legal_aid_application:) }
        let(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }

        let(:applicant) do
          create(:applicant,
                 first_name: "Shery",
                 last_name: "Ledner",
                 last_name_at_birth: "Ledner",
                 national_insurance_number: "EG587804M",
                 date_of_birth: Date.new(1977, 4, 10),
                 address:,
                 has_partner: false)
        end

        let(:chances_of_success_attributes) do
          %w[
            FAM_PROSP_50_OR_BETTER
            FAM_PROSP_BORDER_UNCERT_POOR
            FAM_PROSP_MARGINAL
            FAM_PROSP_POOR
            FAM_PROSP_UNCERTAIN
          ]
        end

        context "with a single proceeding with a borderline chance of success" do
          let(:legal_aid_application) do
            create(:legal_aid_application,
                   :with_everything,
                   :with_negative_benefit_check_result,
                   :with_cfe_v6_result,
                   :with_merits_submitted,
                   :with_proceedings,
                   explicit_proceedings: %i[da001],
                   set_lead_proceeding: :da001,
                   applicant:,
                   provider:,
                   office:)
          end

          before do
            proceeding = legal_aid_application.proceedings.find_by(ccms_code: "DA001")
            create(:chances_of_success, proceeding: proceeding, success_prospect: "borderline")
          end

          it "adds FAMILY_PROSPECTS_OF_SUCCESS with value of borderline" do
            block = XmlExtractor.call(request_xml, :proceeding_merits, "FAMILY_PROSPECTS_OF_SUCCESS")
            expect(block).to have_text_response "Borderline"
          end

          it_behaves_like "FAM_PROSP_X attribute omitter"
        end

        context "with a single proceeding without a chances of success object" do
          let(:legal_aid_application) do
            create(:legal_aid_application,
                   :with_everything,
                   :with_negative_benefit_check_result,
                   :with_cfe_v6_result,
                   :with_merits_submitted,
                   :with_proceedings,
                   explicit_proceedings: %i[se014],
                   set_lead_proceeding: :se014,
                   applicant:,
                   provider:,
                   office:)
          end

          it_behaves_like "FAMILY_PROSPECTS_OF_SUCCESS attribute omitter"
          it_behaves_like "FAM_PROSP_X attribute omitter"
        end

        context "with multiple proceedings with and without a chance of success object, lead with chance of success" do
          let(:legal_aid_application) do
            create(:legal_aid_application,
                   :with_everything,
                   :with_negative_benefit_check_result,
                   :with_cfe_v6_result,
                   :with_merits_submitted,
                   applicant:,
                   provider:,
                   office:).tap do |laa|
              create(:proceeding, :se003, proceeding_case_id: 66_000_001, legal_aid_application: laa, lead_proceeding: false)
              create(:proceeding, :da004, :with_chances_of_success, proceeding_case_id: 66_000_002, legal_aid_application: laa, lead_proceeding: true, success_prospect: "likely")
              create(:proceeding, :se014, proceeding_case_id: 66_000_003, legal_aid_application: laa, lead_proceeding: false)
            end
          end

          it_behaves_like "FAM_PROSP_X attribute omitter"

          it "generates FAMILY_PROSPECTS_OF_SUCCESS attribute for DA004" do
            xml_nodeset = XmlExtractor.call(request_xml, :proceeding_merits, nil, "P_66000002")

            expect(xml_nodeset)
              .to have_xml_attributes(
                PROCEEDING_NAME: "DA004",
                FAMILY_PROSPECTS_OF_SUCCESS: "Good",
              )
          end

          it "generates FAMILY_PROSPECTS_OF_SUCCESS attribute for SE003 for the lead proceeding" do
            xml_nodeset = XmlExtractor.call(request_xml, :proceeding_merits, nil, "P_66000001")

            expect(xml_nodeset)
              .to have_xml_attributes(
                PROCEEDING_NAME: "SE003",
                FAMILY_PROSPECTS_OF_SUCCESS: "Good",
              )
          end

          it "generates FAMILY_PROSPECTS_OF_SUCCESS attribute for SE014" do
            xml_nodeset = XmlExtractor.call(request_xml, :proceeding_merits, nil, "P_66000003")

            expect(xml_nodeset)
              .to have_xml_attributes(
                PROCEEDING_NAME: "SE014",
                FAMILY_PROSPECTS_OF_SUCCESS: "Good",
              )
          end
        end

        context "with multiple proceedings with and without a chance of success object, lead without chance of success" do
          let(:legal_aid_application) do
            create(:legal_aid_application,
                   :with_everything,
                   :with_negative_benefit_check_result,
                   :with_cfe_v6_result,
                   :with_merits_submitted,
                   applicant:,
                   provider:,
                   office:).tap do |laa|
              create(:proceeding, :se003, proceeding_case_id: 66_000_001, legal_aid_application: laa, lead_proceeding: true)
              create(:proceeding, :da004, :with_chances_of_success, proceeding_case_id: 66_000_002, legal_aid_application: laa, lead_proceeding: false, success_prospect: "likely")
              create(:proceeding, :se014, proceeding_case_id: 66_000_003, legal_aid_application: laa, lead_proceeding: false)
            end
          end

          it_behaves_like "FAMILY_PROSPECTS_OF_SUCCESS attribute omitter"
          it_behaves_like "FAM_PROSP_X attribute omitter"
        end

        context "with multiple proceedings with different chances of success object" do
          let(:legal_aid_application) do
            create(:legal_aid_application,
                   :with_everything,
                   :with_negative_benefit_check_result,
                   :with_cfe_v6_result,
                   :with_merits_submitted,
                   applicant:,
                   provider:,
                   office:).tap do |laa|
              create(:proceeding, :with_chances_of_success, :da001, proceeding_case_id: 66_000_001, legal_aid_application: laa, lead_proceeding: false, success_prospect: "likely")
              create(:proceeding, :with_chances_of_success, :da002, proceeding_case_id: 66_000_002, legal_aid_application: laa, lead_proceeding: true, success_prospect: "marginal")
              create(:proceeding, :with_chances_of_success, :da004, proceeding_case_id: 66_000_003, legal_aid_application: laa, lead_proceeding: false, success_prospect: "poor")
            end
          end

          it_behaves_like "FAM_PROSP_X attribute omitter"

          it "generates FAMILY_PROSPECTS_OF_SUCCESS for DA001" do
            xml_nodeset = XmlExtractor.call(request_xml, :proceeding_merits, nil, "P_66000001")

            expect(xml_nodeset)
              .to have_xml_attributes(
                PROCEEDING_NAME: "DA001",
                FAMILY_PROSPECTS_OF_SUCCESS: "Marginal",
              )
          end

          it "generates the chance of success attributes for DA002" do
            xml_nodeset = XmlExtractor.call(request_xml, :proceeding_merits, nil, "P_66000002")

            expect(xml_nodeset)
              .to have_xml_attributes(
                PROCEEDING_NAME: "DA002",
                FAMILY_PROSPECTS_OF_SUCCESS: "Marginal", # TODO: AP-5975 - This is the lead proceedings value. is that correct?
              )
          end

          it "generates the chance of success attributes for DA004" do
            xml_nodeset = XmlExtractor.call(request_xml, :proceeding_merits, nil, "P_66000003")

            expect(xml_nodeset)
              .to have_xml_attributes(
                PROCEEDING_NAME: "DA004",
                FAMILY_PROSPECTS_OF_SUCCESS: "Marginal", # TODO: AP-5975 - This is the lead proceedings value. is that correct?
              )
          end
        end
      end
    end
  end
end
