require "rails_helper"

module CCMS
  module Requestors
    RSpec.describe SpecialChildrenActCaseAddRequestor, :ccms do
      describe "#call" do
        let(:expected_tx_id) { "202011241154290000006983477" }

        let(:legal_aid_application) do
          create(:legal_aid_application,
                 :with_sca_state_machine,
                 :with_positive_benefit_check_result,
                 :with_merits_submitted,
                 :with_proceedings,
                 :with_delegated_functions_on_proceedings,
                 explicit_proceedings: %i[pb003],
                 set_lead_proceeding: :pb003,
                 df_options: { PB003: [10.days.ago.to_date, 1.day.ago.to_date] },
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
        let(:proceeding) { legal_aid_application.proceedings.detect { |p| p.ccms_code == "PB003" } }
        let(:last_name_at_birth) { nil }
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
          create(:cfe_v6_result, submission: cfe_submission)
          create(:involved_child, full_name: "First TestChild", date_of_birth: Date.parse("2019-01-20"), legal_aid_application:)
          create(:involved_child, full_name: "Second TestChild", date_of_birth: Date.parse("2020-02-15"), legal_aid_application:)
          legal_aid_application.reload
          legal_aid_application.update!(opponents:)
          allow(Rails.configuration.x.ccms_soa).to receive_messages(client_username: "FakeUser", client_password: "FakePassword", client_password_type: "password_type")
          allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
          allow(legal_aid_application).to receive(:calculation_date).and_return(Date.new(2020, 3, 25))
          allow(proceeding).to receive(:proceeding_case_id).and_return(55_000_001)
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

          it "invokes the faraday soap_call" do
            expect(soap_call).to receive(:call).with(expected_xml).once
            requestor.call
          end
        end

        describe "auto-granting" do
          it "sets the SCA_AUTO_GRANT to true" do
            block = XmlExtractor.call(request_xml, :global_merits, "SCA_AUTO_GRANT")
            expect(block).to have_boolean_response true
          end

          it "sets the APPLY_CASE_MEANS_REVIEW value to true (no caseworker review needed)" do
            block = XmlExtractor.call(request_xml, :global_merits, "APPLY_CASE_MEANS_REVIEW")
            expect(block).to have_boolean_response true
          end

          it "sets the MEANS_TASK_AUTO_GEN value to true" do
            block = XmlExtractor.call(request_xml, :global_means, "MEANS_TASK_AUTO_GEN")
            expect(block).to have_boolean_response true
          end
        end

        describe "ownership" do
          it "sets CASE_OWNER_SCA to true" do
            block = XmlExtractor.call(request_xml, :global_merits, "CASE_OWNER_SCA")
            expect(block).to have_boolean_response true
          end

          it "sets CASE_OWNER_STD_FAMILY_MERITS to false" do
            block = XmlExtractor.call(request_xml, :global_merits, "CASE_OWNER_STD_FAMILY_MERITS")
            expect(block).to have_boolean_response false
          end
        end

        describe "routing" do
          it "sets MERITS_ROUTING_NAME" do
            block = XmlExtractor.call(request_xml, :global_merits, "MERITS_ROUTING_NAME")
            expect(block).to have_text_response "SCA"
          end

          it "sets MERITS_ROUTING" do
            block = XmlExtractor.call(request_xml, :global_merits, "MERITS_ROUTING")
            expect(block).to have_text_response "SCA"
          end
        end

        describe "parental_responsibility values" do
          context "when its a secure accommodation order proceeding and the client is a child" do
            before { proceeding.update!(ccms_code: "PB006", client_involvement_type_ccms_code: "W") }

            it "sets CLIENT_CHILD_SUBJECT_TO_SAO" do
              block = XmlExtractor.call(request_xml, :global_merits, "CLIENT_CHILD_SUBJECT_TO_SAO")
              expect(block).to have_boolean_response true
            end

            it "sets CLIENT_CHILD_SUBJECT_OF_PROC" do
              block = XmlExtractor.call(request_xml, :global_merits, "CLIENT_CHILD_SUBJECT_OF_PROC")
              expect(block).to have_boolean_response true
            end
          end

          context "when its a non SAO proceeding and the client is a child" do
            before { proceeding.update!(client_involvement_type_ccms_code: "W") }

            it "excludes the CLIENT_CHILD_SUBJECT_TO_SAO block" do
              block = XmlExtractor.call(request_xml, :global_merits, "CLIENT_CHILD_SUBJECT_TO_SAO")
              expect(block).not_to be_present
            end

            it "sets CLIENT_CHILD_SUBJECT_OF_PROC" do
              block = XmlExtractor.call(request_xml, :global_merits, "CLIENT_CHILD_SUBJECT_OF_PROC")
              expect(block).to have_boolean_response true
            end
          end

          context "when the parent is the biological parent of the children" do
            before { applicant.update!(relationship_to_children: "biological") }

            it "sets CLIENT_PARENT_OF_CHILD_PROC" do
              block = XmlExtractor.call(request_xml, :global_merits, "CLIENT_PARENT_OF_CHILD_PROC")
              expect(block).to have_boolean_response true
            end

            it "excludes the CLIENT_HAS_PR" do
              block = XmlExtractor.call(request_xml, :global_merits, "CLIENT_HAS_PR")
              expect(block).not_to be_present
            end

            it "sets MERITS_EVIDENCE_REQD block" do
              block = XmlExtractor.call(request_xml, :global_merits, "MERITS_EVIDENCE_REQD")
              expect(block).to have_boolean_response false
            end

            it "excludes the CLIENT_HAS_PR_ORDER block" do
              block = XmlExtractor.call(request_xml, :global_merits, "CLIENT_HAS_PR_ORDER")
              expect(block).not_to be_present
            end

            it "sets EVIDENCE_COPY_PR_ORDER block" do
              block = XmlExtractor.call(request_xml, :global_merits, "EVIDENCE_COPY_PR_ORDER")
              expect(block).to have_boolean_response false
            end

            it "excludes the COPY_PR_ORDER block" do
              block = XmlExtractor.call(request_xml, :global_merits, "COPY_PR_ORDER")
              expect(block).not_to be_present
            end

            it "excludes the SCA_PR_AGREEMENT block" do
              block = XmlExtractor.call(request_xml, :global_merits, "SCA_PR_AGREEMENT")
              expect(block).not_to be_present
            end

            it "sets EVIDENCE_PR_AGREEMENT block" do
              block = XmlExtractor.call(request_xml, :global_merits, "EVIDENCE_PR_AGREEMENT")
              expect(block).to have_boolean_response false
            end

            it "excludes the COPY_PR_AGREEMENT block" do
              block = XmlExtractor.call(request_xml, :global_merits, "COPY_PR_AGREEMENT")
              expect(block).not_to be_present
            end
          end

          context "when the parent has a parental responsibility agreement of the children" do
            before { applicant.update!(relationship_to_children: "parental_responsibility_agreement") }

            it "excludes the CLIENT_PARENT_OF_CHILD_PROC" do
              block = XmlExtractor.call(request_xml, :global_merits, "CLIENT_PARENT_OF_CHILD_PROC")
              expect(block).not_to be_present
            end

            it "sets CLIENT_HAS_PR" do
              block = XmlExtractor.call(request_xml, :global_merits, "CLIENT_HAS_PR")
              expect(block).to have_boolean_response true
            end

            it "sets MERITS_EVIDENCE_REQD block" do
              block = XmlExtractor.call(request_xml, :global_merits, "MERITS_EVIDENCE_REQD")
              expect(block).to have_boolean_response true
            end

            it "excludes the CLIENT_HAS_PR_ORDER block" do
              block = XmlExtractor.call(request_xml, :global_merits, "CLIENT_HAS_PR_ORDER")
              expect(block).not_to be_present
            end

            it "sets EVIDENCE_COPY_PR_ORDER block" do
              block = XmlExtractor.call(request_xml, :global_merits, "EVIDENCE_COPY_PR_ORDER")
              expect(block).to have_boolean_response false
            end

            it "excludes the COPY_PR_ORDER block" do
              block = XmlExtractor.call(request_xml, :global_merits, "COPY_PR_ORDER")
              expect(block).not_to be_present
            end

            it "sets SCA_PR_AGREEMENT block" do
              block = XmlExtractor.call(request_xml, :global_merits, "SCA_PR_AGREEMENT")
              expect(block).to have_boolean_response true
            end

            it "sets EVIDENCE_PR_AGREEMENT block" do
              block = XmlExtractor.call(request_xml, :global_merits, "EVIDENCE_PR_AGREEMENT")
              expect(block).to have_boolean_response true
            end

            it "sets COPY_PR_AGREEMENT block" do
              block = XmlExtractor.call(request_xml, :global_merits, "COPY_PR_AGREEMENT")
              expect(block).to have_boolean_response true
            end

            it "sets the SCA_AUTO_GRANT to false" do
              block = XmlExtractor.call(request_xml, :global_merits, "SCA_AUTO_GRANT")
              expect(block).to have_boolean_response false
            end

            it "excludes the MEANS_TASK_AUTO_GEN block" do
              block = XmlExtractor.call(request_xml, :global_means, "MEANS_TASK_AUTO_GEN")
              expect(block).not_to be_present
            end

            it "leaves APPLY_CASE_MEANS_REVIEW value as true (no means caseworker review needed)" do
              # Only merits caseworker review should be needed
              block = XmlExtractor.call(request_xml, :global_merits, "APPLY_CASE_MEANS_REVIEW")
              expect(block).to have_boolean_response true
            end
          end

          context "when the parent has court ordered parental responsibility of the children" do
            before { applicant.update!(relationship_to_children: "court_order") }

            it "sets CLIENT_PARENT_OF_CHILD_PROC" do
              block = XmlExtractor.call(request_xml, :global_merits, "CLIENT_PARENT_OF_CHILD_PROC")
              expect(block).not_to be_present
            end

            it "sets CLIENT_HAS_PR" do
              block = XmlExtractor.call(request_xml, :global_merits, "CLIENT_HAS_PR")
              expect(block).to have_boolean_response true
            end

            it "sets MERITS_EVIDENCE_REQD block" do
              block = XmlExtractor.call(request_xml, :global_merits, "MERITS_EVIDENCE_REQD")
              expect(block).to have_boolean_response true
            end

            it "sets CLIENT_HAS_PR_ORDER block" do
              block = XmlExtractor.call(request_xml, :global_merits, "CLIENT_HAS_PR_ORDER")
              expect(block).to have_boolean_response true
            end

            it "sets EVIDENCE_COPY_PR_ORDER block" do
              block = XmlExtractor.call(request_xml, :global_merits, "EVIDENCE_COPY_PR_ORDER")
              expect(block).to have_boolean_response true
            end

            it "sets COPY_PR_ORDER block" do
              block = XmlExtractor.call(request_xml, :global_merits, "COPY_PR_ORDER")
              expect(block).to have_boolean_response true
            end

            it "excludes the SCA_PR_AGREEMENT block" do
              block = XmlExtractor.call(request_xml, :global_merits, "SCA_PR_AGREEMENT")
              expect(block).not_to be_present
            end

            it "sets EVIDENCE_PR_AGREEMENT block" do
              block = XmlExtractor.call(request_xml, :global_merits, "EVIDENCE_PR_AGREEMENT")
              expect(block).to have_boolean_response false
            end

            it "excludes the COPY_PR_AGREEMENT block" do
              block = XmlExtractor.call(request_xml, :global_merits, "COPY_PR_AGREEMENT")
              expect(block).not_to be_present
            end

            it "sets the SCA_AUTO_GRANT to false" do
              block = XmlExtractor.call(request_xml, :global_merits, "SCA_AUTO_GRANT")
              expect(block).to have_boolean_response false
            end

            it "leaves APPLY_CASE_MEANS_REVIEW value as true (no means caseworker review needed)" do
              # Only merits caseworker review should be needed
              block = XmlExtractor.call(request_xml, :global_merits, "APPLY_CASE_MEANS_REVIEW")
              expect(block).to have_boolean_response true
            end
          end
        end

        describe "proceeding type records" do
          context "when the application contains only a core proceeding" do
            it "sets APP_INCLUDES_SCA_PROCS to true" do
              block = XmlExtractor.call(request_xml, :global_merits, "APP_INCLUDES_SCA_PROCS")
              expect(block).to have_boolean_response true
            end

            it "excludes the APP_IS_SCA_RELATED block" do
              block = XmlExtractor.call(request_xml, :global_merits, "APP_IS_SCA_RELATED")
              expect(block).not_to be_present, "Expected block for attribute APP_IS_SCA_RELATED not to be generated, but was \n #{block}"
            end
          end

          context "when the application contains both a core and related proceeding" do
            let(:legal_aid_application) do
              create(:legal_aid_application,
                     :with_sca_state_machine,
                     :with_positive_benefit_check_result,
                     :with_merits_submitted,
                     :with_proceedings,
                     :with_delegated_functions_on_proceedings,
                     explicit_proceedings: %i[pb003 pb007],
                     set_lead_proceeding: :pb003,
                     df_options: { PB003: [10.days.ago.to_date, 1.day.ago.to_date] },
                     applicant:,
                     vehicles:,
                     other_assets_declaration:,
                     savings_amount:,
                     provider:,
                     opponents:,
                     domestic_abuse_summary:,
                     office:)
            end

            describe "it does not auto-grant" do
              it "sets the SCA_AUTO_GRANT to false" do
                block = XmlExtractor.call(request_xml, :global_merits, "SCA_AUTO_GRANT")
                expect(block).to have_boolean_response false
              end

              it "leaves APPLY_CASE_MEANS_REVIEW value as true (no means caseworker review needed)" do
                # Only merits caseworker review should be needed
                block = XmlExtractor.call(request_xml, :global_merits, "APPLY_CASE_MEANS_REVIEW")
                expect(block).to have_boolean_response true
              end
            end

            it "sets APP_INCLUDES_SCA_PROCS to true" do
              block = XmlExtractor.call(request_xml, :global_merits, "APP_INCLUDES_SCA_PROCS")
              expect(block).to have_boolean_response true
            end

            it "sets APP_IS_SCA_RELATED to true" do
              block = XmlExtractor.call(request_xml, :global_merits, "APP_IS_SCA_RELATED")
              expect(block).to have_boolean_response true
            end
          end
        end

        context "when the application has been backdated using delegated functions" do
          it "sets DelegatedFunctionsApply to false" do
            expect(request_xml).to have_xml("//casebio:DelegatedFunctionsApply", "false")
          end

          it "sets the SCA_AUTO_GRANT to true" do
            block = XmlExtractor.call(request_xml, :global_merits, "SCA_AUTO_GRANT")
            expect(block).to have_boolean_response true
          end

          it "sets the SCA_DEVOLVED_POWERS to true" do
            block = XmlExtractor.call(request_xml, :global_merits, "SCA_DEVOLVED_POWERS")
            expect(block).to have_boolean_response true
          end

          it "sets the DATE_DEVOLVED_POWERS_USED to the DF date" do
            block = XmlExtractor.call(request_xml, :global_merits, "DATE_DEVOLVED_POWERS_USED")
            expect(block).to have_date_response(10.days.ago.strftime("%d-%m-%Y"))
          end

          it "sets the PROC_DELEGATED_FUNCTIONS_DATE to the DF date" do
            block = XmlExtractor.call(request_xml, :global_merits, "PROC_DELEGATED_FUNCTIONS_DATE")
            expect(block).to have_date_response(10.days.ago.strftime("%d-%m-%Y"))
          end

          it "excludes the FAMILY_PROSPECTS_OF_SUCCESS block" do
            # this merits question is not asked in SCA proceedings
            block = XmlExtractor.call(request_xml, :proceeding_merits, "FAMILY_PROSPECTS_OF_SUCCESS")
            expect(block).not_to be_present
          end

          it "sets the APPLY_CASE_MEANS_REVIEW value to true (no caseworker review needed)" do
            block = XmlExtractor.call(request_xml, :global_merits, "APPLY_CASE_MEANS_REVIEW")
            expect(block).to have_boolean_response true
          end

          it "sets ApplicationAmendmentType to SUB" do
            block = XmlExtractor.call(request_xml, :application_amendment_type)
            expect(block.children.text).to eq "SUB"
          end

          it "excludes the DevolvedPowersDate block" do
            block = XmlExtractor.call(request_xml, :global_merits, "DEVOLVED_POWERS_DATE")
            expect(block).not_to be_present, "Expected block for attribute DevolvedPowersDate not to be generated, but was \n #{block}"
          end

          it "excludes the DELEG_FUNCTIONS_DATE_MERITS block" do
            block = XmlExtractor.call(request_xml, :global_merits, "DELEG_FUNCTIONS_DATE_MERITS")
            expect(block).not_to be_present
          end

          it "excludes the DELEGATED_FUNCTIONS_DATE block" do
            block = XmlExtractor.call(request_xml, :global_merits, "DELEGATED_FUNCTIONS_DATE")
            expect(block).not_to be_present
          end
        end

        context "when the application is not backdated" do
          let(:legal_aid_application) do
            create(:legal_aid_application,
                   :with_sca_state_machine,
                   :with_positive_benefit_check_result,
                   :with_merits_submitted,
                   :with_proceedings,
                   explicit_proceedings: %i[pb003],
                   set_lead_proceeding: :pb003,
                   applicant:,
                   vehicles:,
                   other_assets_declaration:,
                   savings_amount:,
                   provider:,
                   opponents:,
                   domestic_abuse_summary:,
                   office:)
          end

          it "sets DelegatedFunctionsApply to false" do
            expect(request_xml).to have_xml("//casebio:DelegatedFunctionsApply", "false")
          end

          it "sets the SCA_AUTO_GRANT to true" do
            block = XmlExtractor.call(request_xml, :global_merits, "SCA_AUTO_GRANT")
            expect(block).to have_boolean_response true
          end

          it "sets the SCA_DEVOLVED_POWERS to false" do
            block = XmlExtractor.call(request_xml, :global_merits, "SCA_DEVOLVED_POWERS")
            expect(block).to have_boolean_response false
          end

          it "excludes the DATE_DEVOLVED_POWERS_USED block" do
            block = XmlExtractor.call(request_xml, :global_merits, "DATE_DEVOLVED_POWERS_USED")
            expect(block).not_to be_present
          end

          it "excludes the PROC_DELEGATED_FUNCTIONS_DATE block" do
            block = XmlExtractor.call(request_xml, :global_merits, "PROC_DELEGATED_FUNCTIONS_DATE")
            expect(block).not_to be_present
          end

          it "excludes the FAMILY_PROSPECTS_OF_SUCCESS block" do
            # this merits question is not asked in SCA proceedings
            block = XmlExtractor.call(request_xml, :proceeding_merits, "FAMILY_PROSPECTS_OF_SUCCESS")
            expect(block).not_to be_present
          end

          it "sets the APPLY_CASE_MEANS_REVIEW value to true (no caseworker review needed)" do
            block = XmlExtractor.call(request_xml, :global_merits, "APPLY_CASE_MEANS_REVIEW")
            expect(block).to have_boolean_response true
          end

          it "sets ApplicationAmendmentType to SUB" do
            block = XmlExtractor.call(request_xml, :application_amendment_type)
            expect(block.children.text).to eq "SUB"
          end

          it "excludes the DevolvedPowersDate" do
            block = XmlExtractor.call(request_xml, :global_merits, "DEVOLVED_POWERS_DATE")
            expect(block).not_to be_present, "Expected block for attribute DevolvedPowersDate not to be generated, but was \n #{block}"
          end
        end
      end
    end
  end
end
