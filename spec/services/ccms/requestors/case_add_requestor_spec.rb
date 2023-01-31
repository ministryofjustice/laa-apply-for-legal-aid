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
                 vehicle:,
                 other_assets_declaration:,
                 savings_amount:,
                 provider:,
                 opponent:,
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
        let!(:chances_of_success) do
          create(:chances_of_success, :with_optional_text, proceeding:)
        end
        let(:vehicle) { create(:vehicle, estimated_value: 3030, payment_remaining: 881, purchased_on: Date.new(2008, 8, 22), used_regularly: true) }
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
        let(:opponent) { create(:opponent, first_name: "Joffrey", last_name: "Test-Opponent", police_notified: true) }
        let(:submission) { create(:submission, :case_ref_obtained, case_ccms_reference: "300000000001", legal_aid_application:) }
        let(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }
        let!(:cfe_result) { create(:cfe_v3_result, submission: cfe_submission) }
        let(:office) { create(:office, ccms_id: "4727432767") }
        let(:savings_amount) { create(:savings_amount, :all_nil) }
        let(:soap_client_double) { Savon.client(env_namespace: :soap, wsdl: requestor.__send__(:wsdl_location)) }
        let(:expected_soap_operation) { :create_case_application }
        let(:expected_xml) { requestor.__send__(:request_xml) }
        let(:requestor) { described_class.new(submission, {}) }
        let!(:involved_child1) { create(:involved_child, full_name: "First TestChild", date_of_birth: Date.parse("2019-01-20"), legal_aid_application:) }
        let!(:involved_child2) { create(:involved_child, full_name: "Second TestChild", date_of_birth: Date.parse("2020-02-15"), legal_aid_application:) }

        before do
          legal_aid_application.reload
          allow(Rails.configuration.x.ccms_soa).to receive(:client_username).and_return("FakeUser")
          allow(Rails.configuration.x.ccms_soa).to receive(:client_password).and_return("FakePassword")
          allow(Rails.configuration.x.ccms_soa).to receive(:client_password_type).and_return("password_type")
          allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
          allow(legal_aid_application).to receive(:calculation_date).and_return(Date.new(2020, 3, 25))
        end

        before do
          allow_any_instance_of(Proceeding).to receive(:proceeding_case_id).and_return(55_000_001)
        end

        it "calls the savon soap client" do
          expect(soap_client_double).to receive(:call).with(expected_soap_operation, xml: expected_xml)
          expect(requestor).to receive(:soap_client).and_return(soap_client_double)
          requestor.call
        end

        it "generates the expected xml" do
          expect(CCMS::OpponentId).to receive(:next_serial_id).and_return(88_123_456, 88_123_457, 88_123_458)
          travel_to Time.zone.parse("2020-11-24T11:54:29.000") do
            test_data_xml = ccms_data_from_file "case_add_request.xml"
            expect(expected_xml).to eq test_data_xml
          end
        end

        context "when the proceeding type has a chosen client involvement type" do
          before { proceeding.update!(client_involvement_type_ccms_code: "D", client_involvement_type_description: "Defendant/respondent") }

          it "generates the expected code" do
            expect(CCMS::OpponentId).to receive(:next_serial_id).and_return(88_123_456, 88_123_457, 88_123_458)
            travel_to Time.zone.parse("2020-11-24T11:54:29.000") do
              test_data_xml = ccms_data_from_file "non_default_client_involvement_type.xml"
              expect(expected_xml).to eq test_data_xml
            end
          end
        end

        context "when DF assigned scope limitations are present" do
          context "when DF are not used" do
            it "does not add the extra scope limitation to the XML, and specifies the AA001 for requested scope" do
              expect(CCMS::OpponentId).to receive(:next_serial_id).and_return(88_123_456, 88_123_457, 88_123_458)
              travel_to Time.zone.parse("2020-11-24T11:54:29.000") do
                test_data_xml = ccms_data_from_file "case_add_request.xml"
                expect(expected_xml).to eq test_data_xml
              end
            end
          end

          context "when DF are actually used" do
            let(:df_date) { Date.parse("2020-11-23") }

            before do
              proceeding.update!(used_delegated_functions: true, used_delegated_functions_on: df_date, used_delegated_functions_reported_on: df_date)
              legal_aid_application.reload
            end

            it "adds the extra scope limitation to the XML, and specifies MULTIPLE for requested scope" do
              expect(CCMS::OpponentId).to receive(:next_serial_id).and_return(88_123_456, 88_123_457, 88_123_458)
              travel_to Time.zone.parse("2020-11-24T11:54:29.000") do
                test_data_xml = ccms_data_from_file "df_case_add_request.xml"
                expect(expected_xml).to eq test_data_xml
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
              expect(CCMS::OpponentId).to receive(:next_serial_id).and_return(88_123_456, 88_123_457, 88_123_458)
              travel_to Time.zone.parse("2020-11-24T11:54:29.000") do
                expect(expected_xml.squish).to match substantive_scope_limitation_one_xml
                expect(expected_xml.squish).to match substantive_scope_limitation_two_xml
                expect(expected_xml.squish).not_to match emergency_scope_limitation_one_xml
                expect(expected_xml.squish).not_to match emergency_scope_limitation_two_xml
              end
            end

            it "specifies MULTIPLE for requested scope" do
              expect(expected_xml.squish).to match requested_scope_xml
            end
          end

          context "when DF are used" do
            let(:df_date) { Date.parse("2020-11-23") }

            before do
              proceeding.update!(used_delegated_functions: true, used_delegated_functions_on: df_date, used_delegated_functions_reported_on: df_date)
              legal_aid_application.reload
            end

            it "generates the expected scope limitations" do
              expect(CCMS::OpponentId).to receive(:next_serial_id).and_return(88_123_456, 88_123_457, 88_123_458)
              travel_to Time.zone.parse("2020-11-24T11:54:29.000") do
                expect(expected_xml.squish).to match substantive_scope_limitation_one_xml
                expect(expected_xml.squish).to match substantive_scope_limitation_two_xml
                expect(expected_xml.squish).to match emergency_scope_limitation_one_xml
                expect(expected_xml.squish).to match emergency_scope_limitation_two_xml
              end
            end

            it "specifies MULTIPLE for requested scope" do
              expect(expected_xml.squish).to match requested_scope_xml
            end
          end
        end
      end
    end
  end
end
