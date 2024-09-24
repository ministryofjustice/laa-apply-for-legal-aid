require "rails_helper"

module Reports
  module MIS
    RSpec.describe ApplicationDetailCsvLine do
      let(:legal_aid_application) do
        create(:application,
               :with_proceedings,
               :with_delegated_functions_on_proceedings,
               explicit_proceedings: [:da004],
               set_lead_proceeding: :da004,
               df_options: { DA004: [used_delegated_functions_on, used_delegated_functions_reported_on] },
               application_ref: "L-X99-ZZZ",
               applicant:,
               own_home: own_home_status,
               property_value:,
               shared_ownership: shared_ownership_status,
               outstanding_mortgage_amount: outstanding_mortgage,
               percentage_home:,
               provider:,
               office:,
               benefit_check_result:,
               savings_amount:,
               other_assets_declaration:,
               opponents:,
               parties_mental_capacity:,
               domestic_abuse_summary:,
               ccms_submission:,
               own_vehicle: false,
               merits_submitted_at: Time.current)
      end

      let(:application_with_multiple_employments) do
        create(:application,
               :with_proceedings,
               :with_delegated_functions_on_proceedings,
               :with_multiple_employments,
               :with_full_employment_information,
               explicit_proceedings: [:da004],
               set_lead_proceeding: :da004,
               df_options: { DA004: [used_delegated_functions_on, used_delegated_functions_reported_on] },
               application_ref: "L-X99-ZZZ",
               applicant:,
               own_home: own_home_status,
               property_value:,
               shared_ownership: shared_ownership_status,
               outstanding_mortgage_amount: outstanding_mortgage,
               percentage_home:,
               provider:,
               office:,
               benefit_check_result:,
               savings_amount:,
               other_assets_declaration:,
               opponents:,
               parties_mental_capacity:,
               domestic_abuse_summary:,
               ccms_submission:,
               own_vehicle: false,
               merits_submitted_at: Time.current)
      end

      let(:application_without_df) do
        create(:application,
               :with_proceedings,
               application_ref: "L-X99-ZZZ",
               applicant:,
               own_home: own_home_status,
               property_value:,
               shared_ownership: shared_ownership_status,
               outstanding_mortgage_amount: outstanding_mortgage,
               percentage_home:,
               provider:,
               office:,
               benefit_check_result:,
               savings_amount:,
               other_assets_declaration:,
               opponents:,
               parties_mental_capacity:,
               domestic_abuse_summary:,
               ccms_submission:,
               own_vehicle: false,
               merits_submitted_at: Time.current)
      end

      let(:proceeding) { legal_aid_application.proceedings.first }

      let(:applicant) do
        create(:applicant,
               :not_employed,
               first_name: "Johnny",
               last_name: "WALKER",
               date_of_birth:,
               national_insurance_number: "JA293483A")
      end

      let(:provider) do
        create(:provider,
               username: "psr001",
               firm:)
      end

      let(:firm) { create(:firm, name: "Legal beagles") }

      let(:office) { create(:office, code: "1T823E") }

      let(:ccms_submission) { create(:ccms_submission, case_ccms_reference:) }

      let(:benefit_check_result) { create(:benefit_check_result, result: benefit_check_result_text) }

      let(:savings_amount) do
        create(:savings_amount,
               offline_current_accounts: current_acct_val,
               offline_savings_accounts: savings_acct_val,
               cash: cash_val,
               other_person_account: third_pty_val,
               national_savings: nsi_val,
               plc_shares: plc_val,
               peps_unit_trusts_capital_bonds_gov_stocks: bonds_val,
               life_assurance_endowment_policy: la_val,
               none_selected:)
      end

      let(:other_assets_declaration) do
        create(:other_assets_declaration,
               second_home_value:,
               second_home_mortgage:,
               second_home_percentage:,
               timeshare_property_value:,
               land_value:,
               valuable_items_value:,
               inherited_assets_value:,
               money_owed_value:,
               trust_value:,
               none_selected:)
      end

      let(:opponents) do
        create_list(:opponent, 1)
      end

      let(:parties_mental_capacity) do
        create(:parties_mental_capacity,
               understands_terms_of_court_order:,
               understands_terms_of_court_order_details:)
      end

      let(:domestic_abuse_summary) do
        create(:domestic_abuse_summary,
               warning_letter_sent:,
               warning_letter_sent_details:,
               police_notified:,
               police_notified_details:,
               bail_conditions_set:,
               bail_conditions_set_details:)
      end

      let(:proceeding_type) do
        create(:proceeding_type,
               meaning: "Proceeding type meaning",
               description: "Proceeding type description",
               ccms_matter: "Matter type")
      end

      let(:case_ccms_reference) { "42226668880" }
      let(:date_of_birth) { Date.new(2004, 8, 12) }
      let(:own_home_status) { "mortgage" }
      let(:property_value) { 876_200 }
      let(:shared_ownership_status) { "partner_or_ex_partner" }
      let(:outstanding_mortgage) { 397_822 }
      let(:percentage_home) { 50 }
      let(:benefit_check_result_text) { "Yes" }
      let(:dwp_overridden) { "FALSE" }
      let(:hmrc_data) { [] }
      let(:current_acct_val) { 25.44 }
      let(:savings_acct_val) { 266.10 }
      let(:cash_val) { 17 }
      let(:third_pty_val) { 127 }
      let(:nsi_val) { 5 }
      let(:plc_val) { 120 }
      let(:bonds_val) { 374.22 }
      let(:la_val) { 1102.22 }
      let(:none_selected) { nil }

      let(:second_home_value) { 156_000 }
      let(:second_home_mortgage) { 56_000 }
      let(:second_home_percentage) { 50 }
      let(:timeshare_property_value) { 120_555 }
      let(:land_value) { 55_00 }
      let(:valuable_items_value) { 600 }
      let(:inherited_assets_value) { 300 }
      let(:money_owed_value) { 25 }
      let(:trust_value) { 99 }

      let(:understands_terms_of_court_order) { true }
      let(:understands_terms_of_court_order_details) { "Understood" }
      let(:warning_letter_sent) { true }
      let(:warning_letter_sent_details) { "This is a warning" }
      let(:police_notified) { true }
      let(:police_notified_details) { "Police notified" }
      let(:bail_conditions_set) { true }
      let(:bail_conditions_set_details) { "On bail" }

      let(:prospect) { "likely" }
      let(:purpose) { "The reason we are applying" }
      let(:submitted_at) { Time.zone.local(2020, 2, 21, 15, 44, 55) }
      let(:used_delegated_functions_on) { Date.new(2020, 1, 1) }
      let(:used_delegated_functions_reported_on) { Date.new(2020, 2, 21) }
      let(:today) { Time.zone.today.strftime("%F") }

      let(:v4_cfe_result) { create(:cfe_v4_result) }

      before do
        allow(legal_aid_application).to receive(:cfe_result).and_return(v4_cfe_result)
      end

      describe ".call" do
        let(:headers) { described_class.header_row }
        let(:data_row) do
          described_class.call(legal_aid_application)
        end

        describe "application and provider details" do
          context "when there is a single proceeding" do
            it "returns the correct values" do
              expect(value_for("Firm name")).to eq "Legal beagles"
              expect(value_for("User name")).to eq "psr001"
              expect(value_for("Office ID")).to eq "1T823E"
              expect(value_for("Applicant name")).to eq applicant.full_name
              expect(value_for("Applicant age")).to eq applicant.age
              expect(value_for("Non means tested?")).to eq "No"
              expect(value_for("State")).to eq "initiated"
              expect(value_for("CCMS reason")).to be_nil
              expect(value_for("CCMS reference number")).to eq "42226668880"
              expect(value_for("DWP Overridden")).to eq "No"
              expect(value_for("Case Type")).to eq "Passported"
              expect(value_for("Single/Multi Proceedings")).to eq "Single"
              expect(value_for("Matter types")).to eq "Domestic Abuse"
              expect(value_for("Proceeding types selected")).to match(/^Non-molestation order/)
              expect(value_for("Delegated functions used")).to eq "Yes"
              expect(value_for("Delegated functions dates")).to eq "2020-01-01"
              expect(value_for("Delegated functions reported")).to eq "2020-02-21"
              expect(value_for("Application started")).to eq today
              expect(value_for("Application submitted")).to eq today
              expect(value_for("Application deleted")).to eq "No"
              expect(value_for("HMRC data")).to eq "No"
            end

            context "and the DWP check result is negative" do
              let(:benefit_check_result_text) { "No" }

              it "generates Non-Passported" do
                expect(value_for("Case Type")).to eq "Non-Passported"
              end
            end

            context "and Delegated functions were not used" do
              let(:legal_aid_application) { application_without_df }

              it "generates no" do
                expect(value_for("Delegated functions used")).to eq "No"
              end

              it "generates an empty string for the used_on date" do
                expect(value_for("Delegated functions dates")).to eq "n/a"
              end

              it "generates an empty string for the delegated function notification date" do
                expect(value_for("Delegated functions reported")).to eq ""
              end
            end

            context "when in scope of laspo" do
              before { legal_aid_application.update!(in_scope_of_laspo: laspo_answer) }

              describe "true" do
                let(:laspo_answer) { true }

                it "populates with Yes" do
                  expect(value_for("LASPO Question")).to eq "Yes"
                end
              end

              describe "false" do
                let(:laspo_answer) { false }

                it "populates with Yes" do
                  expect(value_for("LASPO Question")).to eq "No"
                end
              end

              describe "nil" do
                let(:laspo_answer) { nil }

                it "populates with Yes" do
                  expect(value_for("LASPO Question")).to eq ""
                end
              end
            end
          end

          context "when no lead proceeding was specified" do
            before do
              legal_aid_application.lead_proceeding.update!(lead_proceeding: false)
              create(:chances_of_success,
                     success_prospect: prospect,
                     application_purpose: purpose,
                     proceeding:)
            end

            describe "chances of success" do
              it "returns the chances of success of the first proceeding, lead or not" do
                expect(value_for("Prospects of success")).to eq "Likely (>50%)"
              end
            end
          end

          context "when there are multiple proceedings" do
            before { setup_multiple_proceedings }

            let(:expected_proceeding_types) { "Child arrangements order (contact), Inherent jurisdiction high court injunction, Non-molestation order" }

            it "generates multiple proceedings content" do
              expect(value_for("Single/Multi Proceedings")).to eq "Multi"
              expect(value_for("Matter types")).to eq "Domestic Abuse, Section 8 orders"
              expect(value_for("Proceeding types selected")).to eq expected_proceeding_types
            end
          end
        end

        describe "own home" do
          context "when own home is set" do
            it "generates the expected values" do
              expect(value_for("Own home?")).to eq "mortgage"
              expect(value_for("Value")).to eq 876_200
              expect(value_for("Outstanding mortgage")).to eq 397_822
              expect(value_for("Shared?")).to eq "partner_or_ex_partner"
              expect(value_for("%age owned")).to eq 50
            end

            context "when own home is not shared" do
              let(:shared_ownership_status) { "no_sole_owner" }

              it "generates values for home not shared" do
                expect(value_for("Own home?")).to eq "mortgage"
                expect(value_for("Value")).to eq 876_200
                expect(value_for("Outstanding mortgage")).to eq 397_822
                expect(value_for("Shared?")).to eq "no_sole_owner"
                expect(value_for("%age owned")).to eq ""
              end
            end

            context "when home owned outright" do
              let(:shared_ownership_status) { "no_sole_owner" }
              let(:own_home_status) { "owned_outright" }

              it "generates values for home not shared" do
                expect(value_for("Own home?")).to eq "owned_outright"
                expect(value_for("Value")).to eq 876_200
                expect(value_for("Outstanding mortgage")).to eq ""
                expect(value_for("Shared?")).to eq "no_sole_owner"
                expect(value_for("%age owned")).to eq ""
              end
            end
          end
        end

        describe "vehicles" do
          context "when there are no vehicles" do
            it "generates blank fields" do
              expect(value_for("Vehicle?")).to eq "No"
              expect(value_for("Vehicle 1 value")).to eq ""
              expect(value_for("Vehicle 1 Outstanding loan?")).to eq ""
              expect(value_for("Vehicle 1 Loan remaining")).to eq ""
              expect(value_for("Vehicle 1 Date purchased")).to eq ""
              expect(value_for("Vehicle 1 In Regular use?")).to eq ""
            end
          end

          context "when there is a vehicle" do
            let(:purchase_date) { Date.new(2020, 1, 1) }
            let(:used_regularly) { true }

            before do
              create_list(:vehicle,
                          3,
                          legal_aid_application:,
                          estimated_value: 12_000,
                          payment_remaining:,
                          used_regularly:,
                          purchased_on: purchase_date)
            end

            context "and it's in regular use, no loan outstanding" do
              let(:payment_remaining) { 0 }

              it "generates the values" do
                expect(value_for("Vehicle?")).to eq 3
                expect(value_for("Vehicle 1 value")).to eq 12_000
                expect(value_for("Vehicle 1 Outstanding loan?")).to eq "No"
                expect(value_for("Vehicle 1 Loan remaining")).to eq ""
                expect(value_for("Vehicle 1 Date purchased")).to eq "2020-01-01"
                expect(value_for("Vehicle 1 In Regular use?")).to eq "Yes"
              end
            end

            context "and it's not in regular use" do
              let(:used_regularly) { false }
              let(:payment_remaining) { 0 }

              it "generates the values" do
                expect(value_for("Vehicle?")).to eq 3
                expect(value_for("Vehicle 1 value")).to eq 12_000
                expect(value_for("Vehicle 1 Outstanding loan?")).to eq "No"
                expect(value_for("Vehicle 1 Loan remaining")).to eq ""
                expect(value_for("Vehicle 1 Date purchased")).to eq "2020-01-01"
                expect(value_for("Vehicle 1 In Regular use?")).to eq "No"
              end
            end

            context "and there is a loan outstanding" do
              let(:payment_remaining) { 4_566 }

              it "generates the values" do
                expect(value_for("Vehicle?")).to eq 3
                expect(value_for("Vehicle 1 value")).to eq 12_000
                expect(value_for("Vehicle 1 Outstanding loan?")).to eq "Yes"
                expect(value_for("Vehicle 1 Loan remaining")).to eq 4_566
                expect(value_for("Vehicle 1 Date purchased")).to eq "2020-01-01"
                expect(value_for("Vehicle 1 In Regular use?")).to eq "Yes"
              end
            end
          end

          describe "savings_amount" do
            context "when the savings amount record does not exist" do
              it "generates nos and blanks" do
                legal_aid_application.update! savings_amount: nil
                savings_amount_bool_attrs.each { |attr| expect(value_for(attr)).to eq "No" }
                savings_amount_value_attrs.each { |attr| expect(value_for(attr)).to eq "" }
              end
            end

            context "when the savings amount record is all nils" do
              it "generates nos and blanks" do
                legal_aid_application.update! savings_amount: create(:savings_amount, :all_nil)
                savings_amount_bool_attrs.each { |attr| expect(value_for(attr)).to eq "No" }
                savings_amount_value_attrs.each { |attr| expect(value_for(attr)).to eq "" }
              end
            end

            context "when the savings amount record is all zeros" do
              it "generates Yes and zero for each attr" do
                legal_aid_application.update! savings_amount: create(:savings_amount, :all_zero)
                savings_amount_bool_attrs.each { |attr| expect(value_for(attr)).to eq "Yes" }
                savings_amount_value_attrs.each { |attr| expect(value_for(attr)).to eq 0.0 }
              end
            end

            context "when the savings amount record is populated" do
              it "generates the correct values" do
                savings_amount_bool_attrs.each { |attr| expect(value_for(attr)).to eq "Yes" }
                expect(value_for("Current acct value")).to eq savings_amount.offline_current_accounts
                expect(value_for("Savings acct value")).to eq savings_amount.offline_savings_accounts
                expect(value_for("Cash value")).to eq savings_amount.cash
                expect(value_for("Third party acct value")).to eq savings_amount.other_person_account
                expect(value_for("NSI and PB value")).to eq savings_amount.national_savings
                expect(value_for("PLC shares value")).to eq savings_amount.plc_shares
                expect(value_for("Govt. stocks, bonds value")).to eq savings_amount.peps_unit_trusts_capital_bonds_gov_stocks
                expect(value_for("Life assurance value")).to eq savings_amount.life_assurance_endowment_policy
              end
            end
          end
        end

        describe "other_assets declaration" do
          context "when it does not exist" do
            it "generates Nos and blanks" do
              legal_aid_application.update! other_assets_declaration: nil
              other_assets_bool_attrs.each { |attr| expect(value_for(attr)).to eq "No" }
              other_assets_value_attrs.each { |attr| expect(value_for(attr)).to eq "" }
            end
          end

          context "when the other assets declaration is all nils" do
            it "generates Nos and blanks" do
              legal_aid_application.update! other_assets_declaration: create(:other_assets_declaration, :all_nil)
              other_assets_bool_attrs.each { |attr| expect(value_for(attr)).to eq "No" }
              other_assets_value_attrs.each { |attr| expect(value_for(attr)).to eq "" }
            end
          end

          context "when the other assets declaration is all zero" do
            it "generates yes and zero" do
              legal_aid_application.update! other_assets_declaration: create(:other_assets_declaration, :all_zero)
              other_assets_bool_attrs.each { |attr| expect(value_for(attr)).to eq "Yes" }
              other_assets_value_attrs.each { |attr| expect(value_for(attr)).to eq 0.0 }
            end
          end

          context "when the other assets declaration has values" do
            it "generates the correct values" do
              other_assets_bool_attrs.each { |attr| expect(value_for(attr)).to eq "Yes" }
              expect(value_for("Valuable items value")).to eq other_assets_declaration.valuable_items_value
              expect(value_for("Second home value")).to eq other_assets_declaration.second_home_value
              expect(value_for("Timeshare value")).to eq other_assets_declaration.timeshare_property_value
              expect(value_for("Land value")).to eq other_assets_declaration.land_value
              expect(value_for("Inheritance value")).to eq other_assets_declaration.inherited_assets_value
              expect(value_for("Money owed value")).to eq other_assets_declaration.money_owed_value
            end
          end
        end

        describe "restrictions" do
          context "without restrictions" do
            it "generates blanks" do
              expect(value_for("Restrictions?")).to eq "No"
              expect(value_for("Restriction details")).to eq ""
            end
          end

          context "with restrictions" do
            it "generates yes and the details" do
              legal_aid_application.update!(has_restrictions: true, restrictions_details: "Bankrupt")
              expect(value_for("Restrictions?")).to eq "Yes"
              expect(value_for("Restriction details")).to eq "Bankrupt"
            end
          end
        end

        describe "parties_mental_capacity" do
          context "when it does not exist" do
            it "generates blanks" do
              legal_aid_application.update! parties_mental_capacity: nil
              expect(value_for("Parties can understand?")).to eq ""
              expect(value_for("Ability to understand details")).to eq ""
            end
          end

          context "when it exists" do
            it "generates the values" do
              expect(value_for("Parties can understand?")).to eq "Yes"
              expect(value_for("Ability to understand details")).to eq parties_mental_capacity.understands_terms_of_court_order_details
            end
          end

          context "when the data begins with a vulnerable character" do
            before { firm.update!(name: "=malicious_code") }

            it "returns the escaped text" do
              expect(value_for("Firm name")).to eq "'=malicious_code"
            end
          end
        end

        describe "domestic_abuse_summary" do
          context "when it does not exist" do
            it "generates blanks" do
              legal_aid_application.update! domestic_abuse_summary: nil
              expect(value_for("Warning letter sent?")).to eq ""
              expect(value_for("Warning letter details")).to eq ""
              expect(value_for("Police notified?")).to eq ""
              expect(value_for("Police notification details")).to eq ""
              expect(value_for("Bail conditions set?")).to eq ""
              expect(value_for("Bail details")).to eq ""
            end
          end

          context "when it exists" do
            it "generates the values" do
              expect(value_for("Warning letter sent?")).to eq "Yes"
              expect(value_for("Warning letter details")).to eq domestic_abuse_summary.warning_letter_sent_details
              expect(value_for("Police notified?")).to eq "Yes"
              expect(value_for("Police notification details")).to eq domestic_abuse_summary.police_notified_details
              expect(value_for("Bail conditions set?")).to eq "Yes"
              expect(value_for("Bail details")).to eq domestic_abuse_summary.bail_conditions_set_details
            end
          end

          context "when the data begins with a vulnerable character" do
            before { firm.update!(name: "=malicious_code") }

            it "returns the escaped text" do
              expect(value_for("Firm name")).to eq "'=malicious_code"
            end
          end
        end

        describe "HMRC data" do
          context "when the applicant is unemployed" do
            it "returns the expected data" do
              expect(value_for("HMRC data")).to eq "No"
              expect(value_for("Employment Status")).to eq "None"
              expect(value_for("HMRC call successful")).to eq "No"
              expect(value_for("Free text required")).to eq "No"
              expect(value_for("Free text optional")).to eq "No"
              expect(value_for("Multi Employment")).to eq "No"
            end
          end

          context "when the applicant is employed" do
            let(:legal_aid_application) do
              create(:application,
                     :with_proceedings,
                     :with_single_employment,
                     transaction_period_finish_on: Date.yesterday,
                     applicant:)
            end

            let(:applicant) do
              create(:applicant,
                     :employed,
                     :with_extra_employment_information,
                     first_name: "Johnny",
                     last_name: "WALKER",
                     date_of_birth:,
                     national_insurance_number: "JA293483A")
            end

            it "returns the expected data" do
              expect(value_for("HMRC data")).to eq "No"
              expect(value_for("Employment Status")).to eq "Employed"
              expect(value_for("HMRC call successful")).to eq "Yes"
              expect(value_for("Free text required")).to eq "No"
              expect(value_for("Free text optional")).to eq "Yes"
              expect(value_for("Multi Employment")).to eq "No"
            end

            context "when the applicant has multiple jobs" do
              let(:legal_aid_application) { application_with_multiple_employments }
              let(:applicant) { create(:applicant, :employed) }

              it "returns the expected data" do
                expect(value_for("HMRC data")).to eq "No"
                expect(value_for("Employment Status")).to eq "Employed"
                expect(value_for("HMRC call successful")).to eq "No"
                expect(value_for("Free text required")).to eq "Yes"
                expect(value_for("Free text optional")).to eq "No"
                expect(value_for("Multi Employment")).to eq "Yes"
              end
            end
          end

          context "when the applicant has multiple employment states" do
            let(:applicant) do
              create(:applicant,
                     :self_employed,
                     :armed_forces,
                     first_name: "Johnny",
                     last_name: "WALKER",
                     date_of_birth:,
                     national_insurance_number: "JA293483A")
            end

            it "returns the expected data" do
              expect(value_for("HMRC data")).to eq "No"
              expect(value_for("Employment Status")).to eq "Self employed, Armed forces"
              expect(value_for("HMRC call successful")).to eq "No"
              expect(value_for("Free text required")).to eq "No"
              expect(value_for("Free text optional")).to eq "No"
              expect(value_for("Multi Employment")).to eq "No"
            end
          end
        end

        describe "partner fields" do
          context "when the applicant does not have a partner" do
            it "returns the expected data" do
              expect(value_for("Has partner?")).to eq "No"
              expect(value_for("Contrary interest?")).to be_nil
              expect(value_for("Partner DWP challenge?")).to be_nil
            end
          end

          context "when the applicant has a partner" do
            before { create(:partner, shared_benefit_with_applicant: true, legal_aid_application:) }

            let(:applicant) do
              create(:applicant,
                     :with_partner,
                     :not_employed,
                     first_name: "Johnny",
                     last_name: "WALKER",
                     date_of_birth:,
                     national_insurance_number: "JA293483A")
            end

            it "returns the expected data" do
              expect(value_for("Has partner?")).to eq "Yes"
              expect(value_for("Contrary interest?")).to eq "No"
              expect(value_for("Partner DWP challenge?")).to eq "Yes"
            end
          end

          context "when the applicant has a partner with a contrary interest" do
            let(:applicant) do
              create(:applicant,
                     :with_partner,
                     :not_employed,
                     partner_has_contrary_interest: true)
            end

            it "returns the expected data" do
              expect(value_for("Has partner?")).to eq "Yes"
              expect(value_for("Contrary interest?")).to eq "Yes"
              expect(value_for("Partner DWP challenge?")).to eq "No"
            end

            context "and the DWP result was overridden with a shared benefit" do
              before { applicant.update!(shared_benefit_with_partner: true) }

              it "returns the expected data" do
                expect(value_for("Partner DWP challenge?")).to eq "Yes"
              end
            end
          end
        end

        describe "linked application fields" do
          context "when the application has no linked applications" do
            it "returns the expected data" do
              expect(value_for("Family linked?")).to eq "No"
              expect(value_for("Family link lead?")).to be_nil
              expect(value_for("Number of family links")).to be_nil
              expect(value_for("Legal Linked?")).to eq "No"
              expect(value_for("Legal link lead?")).to be_nil
              expect(value_for("Number of legal links")).to be_nil
            end
          end

          context "when the application is a lead family linked application" do
            let(:linked_application) { create(:legal_aid_application) }

            before do
              LinkedApplication.create!(lead_application_id: legal_aid_application.id, associated_application_id: linked_application.id, link_type_code: "FC_LEAD", confirm_link: true)
            end

            it "returns the expected data" do
              expect(value_for("Family linked?")).to eq "Yes"
              expect(value_for("Family link lead?")).to eq "Lead"
              expect(value_for("Number of family links")).to eq 2
              expect(value_for("Legal Linked?")).to eq "No"
              expect(value_for("Legal link lead?")).to be_nil
              expect(value_for("Number of legal links")).to be_nil
            end
          end

          context "when the application is an associated family linked application" do
            let(:linked_application) { create(:legal_aid_application) }

            before do
              LinkedApplication.create!(lead_application_id: linked_application.id, associated_application_id: legal_aid_application.id, link_type_code: "FC_LEAD", confirm_link: true)
            end

            it "returns the expected data" do
              expect(value_for("Family linked?")).to eq "Yes"
              expect(value_for("Family link lead?")).to eq "Associated"
              expect(value_for("Number of family links")).to be_nil
              expect(value_for("Legal Linked?")).to eq "No"
              expect(value_for("Legal link lead?")).to be_nil
              expect(value_for("Number of legal links")).to be_nil
            end
          end

          context "when the application is a lead legal linked application" do
            let(:linked_application) { create(:legal_aid_application) }
            let(:another_associated_application) { create(:legal_aid_application) }

            before do
              LinkedApplication.create!(lead_application_id: legal_aid_application.id, associated_application_id: linked_application.id, link_type_code: "LEGAL", confirm_link: true)
              LinkedApplication.create!(lead_application_id: legal_aid_application.id, associated_application_id: another_associated_application.id, link_type_code: "LEGAL", confirm_link: true)
            end

            it "returns the expected data" do
              expect(value_for("Family linked?")).to eq "No"
              expect(value_for("Family link lead?")).to be_nil
              expect(value_for("Number of family links")).to be_nil
              expect(value_for("Legal Linked?")).to eq "Yes"
              expect(value_for("Legal link lead?")).to eq "Lead"
              expect(value_for("Number of legal links")).to eq 3
            end
          end

          context "when the application is an associated legal linked application to a lead application with one other asociated application" do
            let(:lead_application) { create(:legal_aid_application) }
            let(:another_associated_application) { create(:legal_aid_application) }

            before do
              LinkedApplication.create!(lead_application_id: lead_application.id, associated_application_id: legal_aid_application.id, link_type_code: "LEGAL", confirm_link: true)
              LinkedApplication.create!(lead_application_id: lead_application.id, associated_application_id: another_associated_application.id, link_type_code: "LEGAL", confirm_link: true)
            end

            it "returns the expected data" do
              expect(value_for("Family linked?")).to eq "No"
              expect(value_for("Family link lead?")).to be_nil
              expect(value_for("Number of family links")).to be_nil
              expect(value_for("Legal Linked?")).to eq "Yes"
              expect(value_for("Legal link lead?")).to eq "Associated"
              expect(value_for("Number of legal links")).to be_nil
            end
          end

          context "when the application is both a lead family linked application and a lead legal linked application" do
            let(:family_linked_application) { create(:legal_aid_application) }
            let(:legal_linked_application) { create(:legal_aid_application) }

            before do
              LinkedApplication.create!(lead_application_id: legal_aid_application.id, associated_application_id: family_linked_application.id, link_type_code: "FC_LEAD", confirm_link: true)
              LinkedApplication.create!(lead_application_id: legal_aid_application.id, associated_application_id: legal_linked_application.id, link_type_code: "LEGAL", confirm_link: true)
            end

            it "returns the expected data" do
              expect(value_for("Family linked?")).to eq "Yes"
              expect(value_for("Family link lead?")).to eq "Lead"
              expect(value_for("Number of family links")).to eq 2
              expect(value_for("Legal Linked?")).to eq "Yes"
              expect(value_for("Legal link lead?")).to eq "Lead"
              expect(value_for("Number of legal links")).to eq 2
            end
          end

          context "when the provider has started but not completed the linking process" do
            context "when the provider has not selected the lead application to link to" do
              before do
                LinkedApplication.create!(associated_application_id: legal_aid_application.id, link_type_code: "FC_LEAD")
              end

              it "returns the expected data" do
                expect(value_for("Family linked?")).to eq "No"
                expect(value_for("Family link lead?")).to be_nil
                expect(value_for("Number of family links")).to be_nil
                expect(value_for("Legal Linked?")).to eq "No"
                expect(value_for("Legal link lead?")).to be_nil
                expect(value_for("Number of legal links")).to be_nil
              end
            end

            context "when the provider has not confirmed the link" do
              let(:linked_application) { create(:legal_aid_application) }

              before do
                LinkedApplication.create!(lead_application_id: linked_application.id, associated_application_id: legal_aid_application.id, link_type_code: "FC_LEAD")
              end

              it "returns the expected data" do
                expect(value_for("Family linked?")).to eq "No"
                expect(value_for("Family link lead?")).to be_nil
                expect(value_for("Number of family links")).to be_nil
                expect(value_for("Legal Linked?")).to eq "No"
                expect(value_for("Legal link lead?")).to be_nil
                expect(value_for("Number of legal links")).to be_nil
              end
            end
          end
        end

        context "when the applicant age cannot be generated" do
          let(:legal_aid_application) { create(:legal_aid_application, applicant:) }
          let(:applicant) do
            create(:applicant,
                   :with_partner,
                   :not_employed,
                   partner_has_contrary_interest: true)
          end

          it "returns nil" do
            expect(value_for("Applicant age")).to be_nil
          end
        end
      end

      def value_for(name)
        data_row[headers.index(name)]
      end

      def savings_amount_bool_attrs
        [
          "Current acct?",
          "Savings acct?",
          "Cash?",
          "Third party acct?",
          "NSI and PB?",
          "PLC shares?",
          "Govt. stocks, bonds?, etc?",
          "Life assurance?",
        ]
      end

      def savings_amount_value_attrs
        [
          "Current acct value",
          "Savings acct value",
          "Cash value",
          "Third party acct value",
          "NSI and PB value",
          "PLC shares value",
          "Govt. stocks, bonds value",
          "Life assurance value",
        ]
      end

      def other_assets_bool_attrs
        [
          "Valuable items?",
          "Second home?",
          "Timeshare?",
          "Land?",
          "Inheritance?",
          "Money owed?",
        ]
      end

      def other_assets_value_attrs
        [
          "Valuable items value",
          "Second home value",
          "Timeshare value",
          "Land value",
          "Inheritance value",
          "Money owed value",
        ]
      end

      def setup_multiple_proceedings
        legal_aid_application.proceedings.map(&:destroy)
        %i[da001 da004 se013].each do |trait|
          proceeding = create(:proceeding, trait, legal_aid_application:)

          create(:chances_of_success,
                 success_prospect: prospect,
                 application_purpose: purpose,
                 proceeding:)
        end
        legal_aid_application.reload
      end
    end
  end
end
