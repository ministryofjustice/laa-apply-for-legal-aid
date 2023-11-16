require "rails_helper"

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
                 :with_address_for_xml_fixture,
                 first_name: "Shery",
                 last_name: "Ledner",
                 national_insurance_number: "EG587804M",
                 date_of_birth: Date.new(1977, 4, 10),
                 address:)
        end

        let(:proceeding) { legal_aid_application.proceedings.detect { |p| p.ccms_code == "DA001" } }
        let(:chances_of_success) { proceeding.chances_of_success }
        let(:vehicles) { create_list(:vehicle, 1, estimated_value: 3030, payment_remaining: 881, purchased_on: Date.new(2008, 8, 22), used_regularly: true) }
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

        let(:address) { create(:address, postcode: "GH08NY") }
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
          allow(Rails.configuration.x.ccms_soa).to receive(:client_username).and_return("FakeUser")
          allow(Rails.configuration.x.ccms_soa).to receive(:client_password).and_return("FakePassword")
          allow(Rails.configuration.x.ccms_soa).to receive(:client_password_type).and_return("password_type")
          allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
          allow(legal_aid_application).to receive(:calculation_date).and_return(Date.new(2020, 3, 25))
          allow_any_instance_of(Proceeding).to receive(:proceeding_case_id).and_return(55_000_001)
          allow(CCMS::OpponentId).to receive(:next_serial_id).and_return(88_123_456, 88_123_457, 88_123_458)
        end

        it "calls the savon soap client with expected arguments" do
          soap_client = instance_double(Savon::Client)
          allow(soap_client).to receive(:call)
          allow(requestor).to receive(:soap_client).and_return(soap_client)

          requestor.call

          expect(soap_client)
            .to have_received(:call)
            .with(:create_case_application, xml: request_xml)
        end

        it "generates the expected xml" do
          travel_to(request_created_at) do
            request_hash = Hash.from_xml(request_xml).deep_symbolize_keys!
            expected_request_hash = Hash.from_xml(expected_request_xml).deep_symbolize_keys!

            expect(request_hash).to match(expected_request_hash)
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

              expect(request_hash).to match(expected_request_hash)
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

                expect(request_hash).to match(expected_request_hash)
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

                expect(request_hash).to match(expected_request_hash)
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

        context "with a linked application (associated)" do
          before do
            create(:linked_application, lead_application:, associated_application: legal_aid_application, link_type_code: "FC_LEAD")
          end

          let(:lead_application) do
            create(:legal_aid_application, :with_ccms_submission).tap do |lead|
              create(:ccms_submission,
                     :case_completed,
                     legal_aid_application: lead,
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
      end
    end
  end
end
