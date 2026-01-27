require "rails_helper"

# DO NOT EXTEND this spec
# Use the spec/ccms/requestors/case_add_requestor_xml_blocks
# directory and subfiles.
#
module CCMS
  module Requestors
    RSpec.describe CaseAddRequestor, :ccms do
      describe "#call" do
        let(:expected_tx_id) { "202011241154290000006983477" }

        let(:legal_aid_application) do
          create(:legal_aid_application,
                 :with_everything,
                 :with_positive_benefit_check_result,
                 :with_proceedings,
                 :with_merits_submitted,
                 set_lead_proceeding: :da001,
                 applicant:,
                 vehicles:,
                 other_assets_declaration:,
                 savings_amount:,
                 provider:,
                 opponents:,
                 domestic_abuse_summary:,
                 office:)
        end

        let(:applicant) do
          create(:applicant,
                 first_name: "Shery",
                 last_name: "Ledner",
                 last_name_at_birth:,
                 national_insurance_number: "EG587804M",
                 date_of_birth: Date.new(1977, 4, 10),
                 address:,
                 has_partner: false)
        end
        let(:last_name_at_birth) { nil }
        let(:proceeding) { legal_aid_application.proceedings.detect { |p| p.ccms_code == "DA001" } }
        let(:chances_of_success) { proceeding.chances_of_success }
        let(:vehicles) { create_list(:vehicle, 1, estimated_value: 3030, payment_remaining: 881, more_than_three_years_old: true, used_regularly: true) }
        let(:domestic_abuse_summary) { create(:domestic_abuse_summary, :police_notified_true) }

        let(:other_assets_declaration) do
          create(:other_assets_declaration,
                 valuable_items_value: 144_524.74,
                 money_owed_value: 100,
                 inherited_assets_value: 200,
                 land_value: 300,
                 timeshare_property_value: 400,
                 second_home_value: 500,
                 trust_value: 600)
        end

        let(:address) { create(:address, address_line_one: "10 Foobar Lane", address_line_two: "Bluewater", city: "Ipswich", county: "Essex", postcode: "GH08NY") }
        let(:provider) { create(:provider, username: "saturnina", firm:, email: "patrick_rath@example.net") }
        let(:firm) { create(:firm, ccms_id: 169) }
        let(:opponents) { create_list(:opponent, 1, first_name: "Joffrey", last_name: "Test-Opponent") }
        let(:submission) { create(:submission, :case_ref_obtained, case_ccms_reference: "300000000001", legal_aid_application:) }
        let(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }
        let(:cfe_result) { cfe_submission.cfe_result }
        let(:office) { create(:office, ccms_id: "4727432767") }
        let(:savings_amount) { create(:savings_amount, :all_nil) }
        let(:requestor) { described_class.new(submission, {}) }
        let(:involved_child1) { legal_aid_application.reload.involved_children.find_by(first_name: "First", last_name: "TestChild") }
        let(:involved_child2) { legal_aid_application.reload.involved_children.find_by(first_name: "Second", last_name: "TestChild") }

        let(:request_xml) { requestor.__send__(:request_xml) }
        let(:expected_request_xml) { ccms_data_from_file("case_add_request.xml") }
        let(:request_created_at) { Time.zone.parse("2020-11-24T11:54:29.000") }

        before do
          create(:cfe_v3_result, submission: cfe_submission)
          create(:chances_of_success, :with_optional_text, proceeding:)
          create(:involved_child, full_name: "First TestChild", date_of_birth: Date.parse("2019-01-20"), legal_aid_application:)
          create(:involved_child, full_name: "Second TestChild", date_of_birth: Date.parse("2020-02-15"), legal_aid_application:)
          legal_aid_application.reload
          legal_aid_application.update!(opponents:)
          allow(Rails.configuration.x.ccms_soa).to receive_messages(client_username: "FakeUser", client_password: "FakePassword", client_password_type: "password_type")
          allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
          allow(legal_aid_application).to receive(:calculation_date).and_return(Date.new(2020, 3, 25))
          allow_any_instance_of(Proceeding).to receive(:proceeding_case_id).and_return(55_000_001)
          allow(CCMS::OpponentId).to receive(:next_serial_id).and_return(88_123_456, 88_123_457, 88_123_458)
        end

        describe "#call" do
          before do
            allow(Faraday::SoapCall).to receive(:new).and_return(soap_call)
            stub_request(:post, expected_url)
          end

          let(:soap_call) { instance_double(Faraday::SoapCall) }
          let(:expected_xml) { requestor.__send__(:request_xml) }
          let(:expected_url) { extract_url_from(requestor.__send__(:wsdl_location)) }

          it "invokes the fadaday soap_call" do
            expect(soap_call).to receive(:call).with(expected_xml).once
            requestor.call
          end
        end

        it "generates the expected xml" do
          travel_to(request_created_at) do
            request_hash = Hash.from_xml(request_xml).deep_symbolize_keys!
            expected_request_hash = Hash.from_xml(expected_request_xml).deep_symbolize_keys!

            expect(request_hash.as_json).to match_json_expression(expected_request_hash.as_json)
          end
        end

        context "when the client has a different surname at birth" do
          let(:expected_request_xml) { ccms_data_from_file("case_add_request_with_surname_at_birth.xml") }
          let(:last_name_at_birth) { "different" }

          it "generates the expected xml" do
            travel_to(request_created_at) do
              request_hash = Hash.from_xml(request_xml).deep_symbolize_keys!
              expected_request_hash = Hash.from_xml(expected_request_xml).deep_symbolize_keys!

              expect(request_hash.as_json).to match_json_expression(expected_request_hash.as_json)
            end
          end
        end

        context "when the proceeding type has a chosen client involvement type" do
          let(:expected_request_xml) { ccms_data_from_file("non_default_client_involvement_type.xml") }

          before do
            proceeding.update!(client_involvement_type_ccms_code: "D", client_involvement_type_description: "Defendant/respondent")
          end

          it "generates the expected code" do
            travel_to(request_created_at) do
              request_hash = Hash.from_xml(request_xml).deep_symbolize_keys!
              expected_request_hash = Hash.from_xml(expected_request_xml).deep_symbolize_keys!
              expect(request_hash.as_json).to match_json_expression(expected_request_hash.as_json)
            end
          end
        end

        context "when DF assigned scope limitations are present" do
          context "when DF are not used" do
            let(:expected_request_xml) { ccms_data_from_file("case_add_request.xml") }

            it "does not add the extra scope limitation to the XML, and specifies the AA001 for requested scope" do
              travel_to(request_created_at) do
                request_hash = Hash.from_xml(request_xml).deep_symbolize_keys!
                expected_request_hash = Hash.from_xml(expected_request_xml).deep_symbolize_keys!

                expect(request_hash.as_json).to match_json_expression(expected_request_hash.as_json)
              end
            end
          end

          context "when DF are used" do
            before do
              proceeding.update!(used_delegated_functions: true, used_delegated_functions_on: df_date, used_delegated_functions_reported_on: df_date)
              legal_aid_application.reload
            end

            let(:expected_request_xml) { ccms_data_from_file("df_case_add_request.xml") }
            let(:df_date) { Date.parse("2020-11-23") }

            it "adds the extra scope limitation to the XML, and specifies MULTIPLE for requested scope" do
              travel_to(request_created_at) do
                request_hash = Hash.from_xml(request_xml).deep_symbolize_keys!
                expected_request_hash = Hash.from_xml(expected_request_xml).deep_symbolize_keys!

                expect(request_hash.as_json).to match_json_expression(expected_request_hash.as_json)
              end
            end
          end
        end

        context "when multiple scope limitations are present" do
          before do
            proceeding.scope_limitations.create!(
              scope_type: 1,
              code: "FM062",
              meaning: "Final hearing",
              description: "Limited to all steps up to and including final hearing and any action necessary to implement (but not enforce) the order.",
            )
            proceeding.scope_limitations.create!(
              scope_type: 0,
              code: "CV118",
              meaning: "Hearing",
              description: "Limited to all steps up to and including the hearing on [see additional limitation notes]",
            )
          end

          let(:substantive_scope_limitation_one_xml) do
            /<casebio:ScopeLimitation> <casebio:ScopeLimitation>CV118<\/casebio:ScopeLimitation> <casebio:ScopeLimitationWording>Limited to all steps up to and including the hearing on \[see additional limitation notes\]<\/casebio:ScopeLimitationWording> <casebio:DelegatedFunctionsApply>false<\/casebio:DelegatedFunctionsApply> <\/casebio:ScopeLimitation>/
          end

          let(:substantive_scope_limitation_two_xml) do
            /<casebio:ScopeLimitation> <casebio:ScopeLimitation>FM062<\/casebio:ScopeLimitation> <casebio:ScopeLimitationWording>Limited to all steps up to and including final hearing and any action necessary to implement \(but not enforce\) the order\.<\/casebio:ScopeLimitationWording> <casebio:DelegatedFunctionsApply>false<\/casebio:DelegatedFunctionsApply> <\/casebio:ScopeLimitation>/
          end

          let(:emergency_scope_limitation_one_xml) do
            /<casebio:ScopeLimitation> <casebio:ScopeLimitation>CV117<\/casebio:ScopeLimitation> <casebio:ScopeLimitationWording>Limited to Family Help \(Higher\) and to all steps necessary to negotiate and conclude a settlement\. To include the issue of proceedings and representation in those proceedings save in relation to or at a contested final hearing\.<\/casebio:ScopeLimitationWording> <casebio:DelegatedFunctionsApply>true<\/casebio:DelegatedFunctionsApply> <\/casebio:ScopeLimitation>/
          end

          let(:emergency_scope_limitation_two_xml) do
            /<casebio:ScopeLimitation> <casebio:ScopeLimitation>FM062<\/casebio:ScopeLimitation> <casebio:ScopeLimitationWording>Limited to all steps up to and including final hearing and any action necessary to implement \(but not enforce\) the order\.<\/casebio:ScopeLimitationWording> <casebio:DelegatedFunctionsApply>true<\/casebio:DelegatedFunctionsApply> <\/casebio:ScopeLimitation>/
          end

          let(:requested_scope_xml) do
            /<common:Attribute> <common:Attribute>REQUESTED_SCOPE<\/common:Attribute> <common:ResponseType>text<\/common:ResponseType> <common:ResponseValue>MULTIPLE<\/common:ResponseValue> <common:UserDefinedInd>true<\/common:UserDefinedInd> <\/common:Attribute>/
          end

          context "when DF have not been used" do
            it "generates the expected scope limitations" do
              travel_to(request_created_at) do
                expect(request_xml.squish)
                  .to match(substantive_scope_limitation_one_xml)
                  .and match(substantive_scope_limitation_two_xml)

                expect(request_xml.squish).not_to match emergency_scope_limitation_one_xml
                expect(request_xml.squish).not_to match emergency_scope_limitation_two_xml
              end
            end

            it "specifies MULTIPLE for requested scope" do
              expect(request_xml.squish).to match requested_scope_xml
            end
          end

          context "when DF are used" do
            let(:df_date) { Date.parse("2020-11-23") }

            before do
              proceeding.update!(used_delegated_functions: true, used_delegated_functions_on: df_date, used_delegated_functions_reported_on: df_date)
              legal_aid_application.reload
            end

            it "generates the expected scope limitations" do
              travel_to(request_created_at) do
                expect(request_xml.squish)
                  .to match(substantive_scope_limitation_one_xml)
                  .and match(substantive_scope_limitation_two_xml)
                  .and match(emergency_scope_limitation_one_xml)
                  .and match(emergency_scope_limitation_two_xml)
              end
            end

            it "specifies MULTIPLE for requested scope" do
              expect(request_xml.squish).to match requested_scope_xml
            end
          end
        end

        context "with multiple individual opponents" do
          let(:opponent_one) { create(:opponent, first_name: "Joffrey", last_name: "Baratheon") }
          let(:opponent_two) { create(:opponent, first_name: "Sansa", last_name: "Stark") }
          let(:opponents) { [opponent_one, opponent_two] }

          before do
            allow(CCMS::OpponentId).to receive(:next_serial_id).and_return(99_123_456, 99_123_457)
          end

          it "generates expected xml" do
            other_party_xpath = "//casebio:OtherParties/casebio:OtherParty"
            person_xpath = "#{other_party_xpath}/casebio:OtherPartyDetail/casebio:Person"

            expect(request_xml)
              .to have_xml("#{other_party_xpath}/casebio:OtherPartyID", "OPPONENT_99123456")
              .and have_xml("#{other_party_xpath}/casebio:SharedInd", "false")
              .and have_xml("#{person_xpath}/casebio:Name/common:Title", "")
              .and have_xml("#{person_xpath}/casebio:Name/common:FirstName", "Joffrey")
              .and have_xml("#{person_xpath}/casebio:Name/common:Surname", "Baratheon")
              .and have_xml("#{person_xpath}/casebio:RelationToClient", "UNKNOWN")
              .and have_xml("#{person_xpath}/casebio:RelationToCase", "OPP")

            expect(request_xml)
              .to have_xml("#{other_party_xpath}/casebio:OtherPartyID", "OPPONENT_99123457")
              .and have_xml("#{other_party_xpath}/casebio:SharedInd", "false")
              .and have_xml("#{person_xpath}/casebio:Name/common:Title", "")
              .and have_xml("#{person_xpath}/casebio:Name/common:FirstName", "Sansa")
              .and have_xml("#{person_xpath}/casebio:Name/common:Surname", "Stark")
              .and have_xml("#{person_xpath}/casebio:RelationToClient", "UNKNOWN")
              .and have_xml("#{person_xpath}/casebio:RelationToCase", "OPP")
          end
        end

        context "with a linked application" do
          before do
            create(:linked_application, lead_application:, associated_application: legal_aid_application, link_type_code: "FC_LEAD")
          end

          let(:lead_application) do
            create(:legal_aid_application, :with_ccms_submission).tap do |lead_application|
              create(:ccms_submission,
                     :case_completed,
                     legal_aid_application: lead_application,
                     case_ccms_reference: "300000000001")
            end
          end

          it "generates expected xml" do
            linked_cases_xpath = "//casebio:LinkedCases/casebio:LinkedCase"

            expect(request_xml)
              .to have_xml("#{linked_cases_xpath}/casebio:CaseReferenceNumber", "300000000001")
              .and have_xml("#{linked_cases_xpath}/casebio:LinkType", "FC_LEAD")
          end
        end

        describe "correspondence address handling" do
          let(:applicant) { create(:applicant, same_correspondence_and_home_address:, addresses:) }
          let(:correspondence_address) { create(:address, address_line_one: "109 Correspondence Avenue") }
          let(:home_address) { create(:address, :as_home_address, address_line_one: "27 Home Street") }
          let(:address_xpath) { "//casebio:CaseDetails/casebio:ApplicationDetails/casebio:CorrespondenceAddress" }

          context "when the provider has set the home address to the same as correspondence" do
            let(:same_correspondence_and_home_address) { true }
            let(:correspondence_address) { nil }
            let(:addresses) { [home_address] }

            it "is set to the correspondence address" do
              expect(request_xml)
                .to have_xml("#{address_xpath}/common:AddressLine1", "27 Home Street")
                .and have_xml("#{address_xpath}/common:AddressLine2", home_address.address_line_two)
            end
          end

          context "when the provider has set a different home address" do
            let(:same_correspondence_and_home_address) { false }
            let(:addresses) { [home_address, correspondence_address] }

            it "is set to the expected, separate, home address" do
              expect(request_xml)
                .to have_xml("#{address_xpath}/common:AddressLine1", "109 Correspondence Avenue")
                .and have_xml("#{address_xpath}/common:AddressLine2", correspondence_address.address_line_two)
            end
          end

          context "when the record was created before the home_address flag was enabled" do
            let(:same_correspondence_and_home_address) { nil }
            let(:home_address) { nil }
            let(:addresses) { [correspondence_address] }

            it "is set to the correspondence address" do
              expect(request_xml)
                .to have_xml("#{address_xpath}/common:AddressLine1", "109 Correspondence Avenue")
                .and have_xml("#{address_xpath}/common:AddressLine2", correspondence_address.address_line_two)
            end
          end
        end

        describe "care of address handling" do
          let(:applicant) { create(:applicant, address:) }
          let(:address) do
            create(:address,
                   care_of:,
                   care_of_first_name:,
                   care_of_last_name:,
                   care_of_organisation_name:)
          end
          let(:care_of) { nil }
          let(:care_of_first_name) { nil }
          let(:care_of_last_name) { nil }
          let(:care_of_organisation_name) { nil }
          let(:address_xpath) { "//casebio:CaseDetails/casebio:ApplicationDetails/casebio:CorrespondenceAddress" }

          context "when care of is not set" do
            it "does not add the xml key" do
              expect(request_xml).not_to match "common:CoFFName"
            end
          end

          context "when care of is set to an individual" do
            let(:care_of) { "person" }
            let(:care_of_first_name) { "James" }
            let(:care_of_last_name) { "Bond" }

            it "records the care of name" do
              expect(request_xml)
                .to have_xml("#{address_xpath}/common:CoffName", "James Bond")
            end
          end

          context "when care of is set to an organisation" do
            let(:care_of) { "organisation" }
            let(:care_of_organisation_name) { "International Exports" }

            it "records the care of organisation name" do
              expect(request_xml)
                .to have_xml("#{address_xpath}/common:CoffName", "International Exports")
            end
          end
        end

        context "when optional address line three field is populated" do
          let(:address) do
            create(:address,
                   address_line_one: "Corporation name",
                   address_line_two: "109 Correspondence Avenue",
                   address_line_three: "Placeholder City")
          end
          let(:address_xpath) { "//casebio:CaseDetails/casebio:ApplicationDetails/casebio:CorrespondenceAddress" }

          it "is included in the payload" do
            expect(request_xml).to have_xml("#{address_xpath}/common:AddressLine1", "Corporation name")
                                     .and have_xml("#{address_xpath}/common:AddressLine2", "109 Correspondence Avenue")
                                     .and have_xml("#{address_xpath}/common:AddressLine3", "Placeholder City")
          end
        end

        describe "non-SCA applications" do
          it "excludes the SCA_AUTO_GRANT block" do
            block = XmlExtractor.call(request_xml, :global_merits, "SCA_AUTO_GRANT")
            expect(block).not_to be_present
          end

          it "excludes the SCA_DEVOLVED_POWERS block" do
            block = XmlExtractor.call(request_xml, :global_merits, "SCA_DEVOLVED_POWERS")
            expect(block).not_to be_present
          end

          it "includes the FAMILY_PROSPECTS_OF_SUCCESS block" do
            # this merits question is asked in all non-SCA proceedings
            block = XmlExtractor.call(request_xml, :proceeding_merits, "FAMILY_PROSPECTS_OF_SUCCESS")
            expect(block).to be_present
          end
        end

        describe "when the application has a PLF Appeal proceeding" do
          let(:legal_aid_application) do
            create(:legal_aid_application,
                   :with_everything,
                   :with_positive_benefit_check_result,
                   :with_second_appeal,
                   :with_proceedings,
                   :with_merits_submitted,
                   explicit_proceedings: %i[pbm01a],
                   set_lead_proceeding: :pbm01a,
                   applicant:,
                   vehicles:,
                   other_assets_declaration:,
                   savings_amount:,
                   provider:,
                   opponents:,
                   domestic_abuse_summary:,
                   office:,
                   second_appeal:,
                   original_judge_level: nil,
                   court_type:)
          end

          let(:proceeding) { legal_aid_application.proceedings.detect { |p| p.ccms_code == "PBM01A" } }

          context "and the provider answered no to the Second Appeal merits question" do
            let(:second_appeal) { false }
            let(:court_type) { "court_of_appeal" }

            it "sets the ECF_FLAG value to false" do
              block = XmlExtractor.call(request_xml, :global_merits, "ECF_FLAG")
              expect(block).to have_boolean_response false
            end

            it "sets MERITS_ROUTING" do
              block = XmlExtractor.call(request_xml, :global_merits, "MERITS_ROUTING")
              expect(block).to have_text_response "SFM"
            end

            it "excludes the MERITS_ROUTING_NAME block" do
              block = XmlExtractor.call(request_xml, :global_merits, "MERITS_ROUTING_NAME")
              expect(block).not_to be_present
            end

            it "sets CASE_OWNER_STD_FAMILY_MERITS to true" do
              block = XmlExtractor.call(request_xml, :global_merits, "CASE_OWNER_STD_FAMILY_MERITS")
              expect(block).to have_boolean_response true
            end

            it "sets ApplicationAmendmentType to SUB" do
              block = XmlExtractor.call(request_xml, :application_amendment_type)
              expect(block.children.text).to eq "SUB"
            end

            it "excludes the MEANS_ROUTING block" do
              block = XmlExtractor.call(request_xml, :global_means, "MEANS_ROUTING")
              expect(block).not_to be_present
            end
          end

          context "and the provider answered yes to the Second Appeal merits question" do
            let(:second_appeal) { true }
            let(:court_type) { "court_of_appeal" }

            it "sets the ECF_FLAG value to true" do
              block = XmlExtractor.call(request_xml, :global_merits, "ECF_FLAG")
              expect(block).to have_boolean_response true
            end

            it "sets MERITS_ROUTING" do
              block = XmlExtractor.call(request_xml, :global_merits, "MERITS_ROUTING")
              expect(block).to have_text_response "ECF"
            end

            it "sets MERITS_ROUTING_NAME" do
              block = XmlExtractor.call(request_xml, :global_merits, "MERITS_ROUTING_NAME")
              expect(block).to have_text_response "ECF Team"
            end

            it "sets CASE_OWNER_STD_FAMILY_MERITS to false" do
              block = XmlExtractor.call(request_xml, :global_merits, "CASE_OWNER_STD_FAMILY_MERITS")
              expect(block).to have_boolean_response false
            end

            it "sets ApplicationAmendmentType to ECF" do
              block = XmlExtractor.call(request_xml, :application_amendment_type)
              expect(block.children.text).to eq "ECF"
            end

            context "when the application is passported" do
              it "sets MEANS_ROUTING to CAM" do
                block = XmlExtractor.call(request_xml, :global_means, "MEANS_ROUTING")
                expect(block).to have_text_response "CAM"
              end
            end
          end

          context "and the client is a respondent" do
            let(:second_appeal) { false }
            let(:court_type) { "court_of_appeal" }

            before do
              proceeding.chances_of_success.destroy!
              proceeding.update!(client_involvement_type_ccms_code: "D",
                                 client_involvement_type_description: "Defendant or respondent")
            end

            it "excludes the FAMILY_PROSPECTS_OF_SUCCESS block" do
              # this merits question is not asked in PLF proceedings where the client is not an Applicant or Joined Party
              block = XmlExtractor.call(request_xml, :proceeding_merits, "FAMILY_PROSPECTS_OF_SUCCESS")
              expect(block).not_to be_present
            end

            it "excludes the PROSPECTS_OF_SUCCESS block" do
              # this merits question is not asked in PLF proceedings where the client is not an Applicant or Joined Party
              block = XmlExtractor.call(request_xml, :proceeding_merits, "PROSPECTS_OF_SUCCESS")
              expect(block).not_to be_present
            end
          end
        end
      end
    end
  end
end
