require "rails_helper"

RSpec.describe Providers::Reports::Means, type: :component do
  let(:legal_aid_application) do
    create(
      :legal_aid_application,
      :with_everything,
      :with_cfe_v5_result,
      :with_proceedings,
      :with_delegated_functions_on_proceedings,
      :assessment_submitted,
      application_ref: "L-123-456",
      applicant:,
      extra_employment_information:,
      extra_employment_information_details:,
      full_employment_details:,
      own_home:,
      property_value:,
      shared_ownership:,
      outstanding_mortgage_amount:,
      percentage_home:,
      own_vehicle:,
      vehicle:,
      savings_amount:,
      other_assets_declaration:,
      policy_disregards:,
      attachments:,
      ccms_submission:,
      explicit_proceedings: %i[da006 da002],
      df_options: { DA006: [Date.parse("2020-01-20")] },
    )
  end

  let(:applicant) do
    build(
      :applicant,
      first_name: "Test",
      last_name: "Person",
      date_of_birth: Date.parse("2000-01-20"),
      bank_providers:,
    )
  end

  let(:extra_employment_information) { nil }
  let(:extra_employment_information_details) { nil }
  let(:full_employment_details) { nil }
  let(:own_home) { nil }
  let(:property_value) { nil }
  let(:shared_ownership) { nil }
  let(:outstanding_mortgage_amount) { nil }
  let(:percentage_home) { nil }
  let(:own_vehicle) { nil }
  let(:vehicle) { nil }
  let(:bank_providers) { [] }
  let(:savings_amount) { nil }
  let(:other_assets_declaration) { nil }
  let(:policy_disregards) { nil }
  let(:permissions) { [] }
  let(:attachments) { [] }

  let(:ccms_submission) { build(:submission, case_ccms_reference: "CCMS-123-456") }

  let(:cfe_result) { legal_aid_application.cfe_result }
  let(:cfe_result_attributes) { {} }

  let(:manual_review_determiner) { CCMS::ManualReviewDeterminer.new(legal_aid_application) }
  let(:manual_review_required?) { false }

  let(:component) { described_class.new(legal_aid_application:, manual_review_determiner:) }

  before do
    stub_manual_review_determiner(result: manual_review_required?)
    stub_cfe_result(cfe_result_attributes)
    update_provider_permissions
    render_inline(component)
  end

  it "renders the heading" do
    expect(page).to have_css("h1", text: "Means report")
  end

  it "renders the application reference" do
    application_reference = summary_list_question("Apply service case reference:")
    expect(application_reference).to have_answer("L-123-456")
  end

  it "renders the CCMS case reference" do
    case_ccms_reference = summary_list_question("CCMS case reference:")
    expect(case_ccms_reference).to have_answer("CCMS-123-456")
  end

  it "does not render any change links" do
    expect(page).not_to have_link("Change")
  end

  describe "client details" do
    it "renders the sub-heading" do
      expect(page).to have_css("h2", text: "Client details")
    end

    it "renders the client's first name" do
      client_name = summary_list_question("First name")
      expect(client_name).to have_answer("Test")
    end

    it "renders the client's last name" do
      last_name = summary_list_question("Last name")
      expect(last_name).to have_answer("Person")
    end

    it "renders the client's date of birth" do
      date_of_birth = summary_list_question("Date of birth")
      expect(date_of_birth).to have_answer("20 January 2000")
    end

    it "renders the client's age" do
      age = summary_list_question("Age at computation date")
      expect(age).to have_answer("20 years old")
    end

    it "does not render the client's address" do
      expect(page).not_to have_css("dt", text: "Correspondence address")
    end

    context "when the client has a national insurance number" do
      let(:applicant) { build(:applicant, national_insurance_number: "QQ123456C") }

      it "renders the client's national insurance number" do
        national_insurance = summary_list_question("National Insurance number")
        expect(national_insurance).to have_answer("QQ123456C")
      end
    end

    context "when the client does not have a national insurance number" do
      let(:applicant) { build(:applicant, national_insurance_number: nil) }

      it "renders the generic message" do
        national_insurance = summary_list_question("National Insurance number")
        expect(national_insurance).to have_answer("Not provided")
      end
    end

    it "does not render the client's email address" do
      expect(page).not_to have_css("dt", text: "Email address")
    end
  end

  describe "proceeding eligibility" do
    context "when the cfe result version is less than 4" do
      let(:legal_aid_application) do
        create(
          :legal_aid_application,
          :with_everything,
          :with_cfe_v3_result,
        )
      end

      it "does not render the sub-heading" do
        expect(page).not_to have_css("h2", text: "Proceeding eligibility")
      end
    end

    context "when the cfe result version is 4 or greater" do
      it "renders the sub-heading" do
        expect(page).to have_css("h2", text: "Proceeding eligibility")
      end

      it "renders the result for each proceeding" do
        proceeding_meanings = legal_aid_application.proceedings.pluck(:meaning)
        proceeding_meanings.each do |meaning|
          proceeding = summary_list_question(meaning)
          expect(proceeding).to have_answer("Yes")
        end
      end
    end
  end

  describe "receives benefits" do
    it "renders the sub-heading" do
      expect(page).to have_css("h2", text: "Passported means")
    end

    it "renders the benefit result" do
      benefit_result = summary_list_question("In receipt of passporting benefit")
      expect(benefit_result).to have_answer("No")
    end
  end

  context "when the legal aid application is non-passported" do
    describe "income result" do
      let(:cfe_result_attributes) do
        {
          total_gross_income_assessed: 1000.50,
          total_disposable_income_assessed: 500.17,
          gross_income_upper_threshold: 1000.25,
          disposable_income_lower_threshold: 500.10,
          disposable_income_upper_threshold: 500.20,
          income_contribution: 250,
        }
      end

      it "renders the sub-heading" do
        expect(page).to have_css("h2", text: "Income result")
      end

      it "renders the gross income" do
        gross_income = summary_list_question("Total gross income assessed")
        expect(gross_income).to have_answer("£1,000.50")
      end

      it "renders the disposable income" do
        dispoable_income = summary_list_question("Total disposable income assessed")
        expect(dispoable_income).to have_answer("£500.17")
      end

      it "renders the gross income limit" do
        gross_income_limit = summary_list_question("Gross income limit")
        expect(gross_income_limit).to have_answer("£1,000.25")
      end

      it "renders the disposable income lower limit" do
        disposable_lower_limit = summary_list_question("Disposable income lower limit")
        expect(disposable_lower_limit).to have_answer("£500.10")
      end

      it "renders the disposable income upper limit" do
        disposable_upper_limit = summary_list_question("Disposable income upper limit")
        expect(disposable_upper_limit).to have_answer("£500.20")
      end

      it "renders the disposable income contribution" do
        income_contribution = summary_list_question("Income contribution")
        expect(income_contribution).to have_answer("£250")
      end
    end

    describe "income details" do
      let(:cfe_result_attributes) { { total_gross_income_assessed: 1234.56 } }

      it "renders the sub-heading" do
        expect(page).to have_css("h2", text: "Income")
      end

      it "renders income details", :aggregate_failures do
        expect(page).to have_transaction_detail(type: :income, text: "Benefits")
        expect(page).to have_transaction_detail(type: :income, text: "Financial help from friends or family")
        expect(page).to have_transaction_detail(type: :income, text: "Maintenance payments")
        expect(page).to have_transaction_detail(type: :income, text: "Income from property or lodger")
        expect(page).to have_transaction_detail(type: :income, text: "Student loan or grant")
        expect(page).to have_transaction_detail(type: :income, text: "Pension")
      end

      it "renders the total income" do
        total_income = summary_list_question("Total income")
        expect(total_income).to have_answer("£1,234.56")
      end
    end

    describe "employed income" do
      let(:extra_employment_information) { true }
      let(:extra_employment_information_details) { "Extra testing details" }

      it "renders the sub-heading" do
        expect(page).to have_css("h3", text: "Employment income")
      end

      it "renders the employment details" do
        employment_details = page.first("dt", text: "Details")
        expect(employment_details).to have_answer("Extra testing details")
      end
    end

    describe "full employment_details" do
      let(:full_employment_details) { "Full testing details" }

      it "renders the sub-heading" do
        expect(page).to have_css("h3", text: "Employment income")
      end

      it "renders the full employment details" do
        employment_details = summary_list_question("Your client's employment details")
        expect(employment_details).to have_answer("Full testing details")
      end
    end

    describe "outgoings details" do
      let(:cfe_result_attributes) { { total_monthly_outgoings: 9876.54 } }

      it "renders the sub-heading" do
        expect(page).to have_css("h2", text: "Outgoings")
      end

      it "renders outgoings details", :aggregate_failures do
        expect(page).to have_transaction_detail(type: :outgoings, text: "Housing payments")
        expect(page).to have_transaction_detail(type: :outgoings, text: "Childcare payments")
        expect(page).to have_transaction_detail(type: :outgoings, text: "Maintenance payments to a former partner")
        expect(page).to have_transaction_detail(type: :outgoings, text: "Payments towards legal aid in a criminal case")
      end

      it "renders the total outgoings" do
        total_outgoings = summary_list_question("Total outgoings")
        expect(total_outgoings).to have_answer("£9,876.54")
      end
    end

    describe "deductions details" do
      let(:cfe_result_attributes) { { total_deductions: 111.12 } }

      it "renders the sub-heading" do
        expect(page).to have_css("h2", text: "Deductions")
      end

      it "renders deductions details", :aggregate_failures do
        expect(page).to have_transaction_detail(type: :deductions, text: "Dependants allowance")
        expect(page).to have_transaction_detail(type: :deductions, text: "Income from benefits excluded from calculation")
      end

      it "renders the total deductions" do
        total_deductions = summary_list_question("Total deductions")
        expect(total_deductions).to have_answer("£111.12")
      end
    end

    describe "caseworker review" do
      context "when manual review is required" do
        let(:manual_review_required?) { true }

        it "renders the sub-heading" do
          expect(page).to have_css("h2", text: "Caseworker Review")
        end
      end

      context "when manual review is not required" do
        let(:manual_review_required?) { false }

        it "renders the sub-heading" do
          expect(page).to have_css("h2", text: "Caseworker Review")
        end
      end
    end
  end

  context "when the legal aid application is passported" do
    let(:legal_aid_application) do
      create(
        :legal_aid_application,
        :with_everything,
        :with_passported_state_machine,
        :with_cfe_v5_result,
        :with_proceedings,
        explicit_proceedings: %i[da006 da002],
      )
    end

    describe "income result" do
      it "does not render the sub-heading" do
        expect(page).not_to have_css("h2", text: "Income result")
      end
    end

    describe "income details" do
      it "does not render the sub-heading" do
        expect(page).not_to have_css("h2", text: "Income")
      end
    end

    describe "employed income" do
      it "does not render the sub-heading" do
        expect(page).not_to have_css("h3", text: "Employment income")
      end
    end

    describe "outgoings details" do
      it "does not render the sub-heading" do
        expect(page).not_to have_css("h2", text: "Outgoings")
      end
    end

    describe "deductions details" do
      it "does not render the sub-heading" do
        expect(page).not_to have_css("h2", text: "Deductions")
      end
    end

    describe "caseworker review" do
      context "when manual review is required" do
        let(:manual_review_required?) { true }

        it "renders the sub-heading" do
          expect(page).to have_css("h2", text: "Caseworker Review")
        end
      end

      context "when manual review is not required" do
        let(:manual_review_required?) { false }

        it "does not render the sub-heading" do
          expect(page).not_to have_css("h2", text: "Caseworker Review")
        end
      end
    end
  end

  describe "capital result" do
    let(:cfe_result_attributes) do
      {
        total_capital: 1234.56,
        capital_contribution: 123.45,
      }
    end

    it "renders the sub-heading" do
      expect(page).to have_css("h2", text: "Capital result")
    end

    it "renders the total capital assessed" do
      total_capital = summary_list_question("Total capital assessed")
      expect(total_capital).to have_answer("£1,234.56")
    end

    it "renders the capital result lower limit" do
      lower_limit = summary_list_question("Capital lower limit")
      expect(lower_limit).to have_answer("£3,000")
    end

    it "renders the capital result upper limit" do
      upper_limit = summary_list_question("Capital upper limit")
      expect(upper_limit).to have_answer("£8,000")
    end

    it "renders the capital contribution" do
      capital_contribution = summary_list_question("Capital contribution")
      expect(capital_contribution).to have_answer("£123.45")
    end
  end

  describe "assets" do
    describe "property" do
      it "renders the sub-heading" do
        expect(page).to have_css("h3", text: "Property")
      end

      context "when the client has their own home" do
        let(:own_home) { "owned_outright" }
        let(:property_value) { 123_456.78 }

        it "renders the home ownership details", :aggregate_failures do
          own_home = summary_list_question("Does your client own the home they live in?")
          expect(own_home).to have_answer("Yes")

          property_value = summary_list_question("How much is your client's home worth?")
          expect(property_value).to have_answer("£123,456.78")
        end

        context "when the property has a mortgage" do
          let(:own_home) { "mortgage" }
          let(:outstanding_mortgage_amount) { 23_456.78 }

          it "renders the outstanding mortgage amount" do
            mortgage_amount = summary_list_question("What is the outstanding mortgage on your client's home?")
            expect(mortgage_amount).to have_answer("£23,456")
          end
        end

        context "when the property does not have a mortgage" do
          let(:own_home) { "owned_outright" }

          it "does not render the outstanding mortgage amount" do
            expect(page).not_to have_content("What is the outstanding mortgage on your client's home?")
          end
        end

        context "when the property has shared ownership" do
          let(:shared_ownership) { "partner_or_ex_partner" }
          let(:percentage_home) { 50 }

          it "renders the ownership percentage", :aggregate_failures do
            shared_ownership = summary_list_question("Does your client own their home with anyone else?")
            expect(shared_ownership).to have_answer("Yes")

            ownership_percentage = summary_list_question("What % share of their home does your client legally own?")
            expect(ownership_percentage).to have_answer("50.00%")
          end
        end

        context "when the property does not have shared ownership" do
          let(:shared_ownership) { "no_sole_owner" }

          it "does not render the ownership percentage" do
            shared_ownership = summary_list_question("Does your client own their home with anyone else?")
            expect(shared_ownership).to have_answer("No")

            expect(page).not_to have_content("What % share of their home does your client legally own?")
          end
        end
      end

      context "when the client does not have their own home" do
        let(:own_home) { "no" }

        it "does not render the home ownership details", :aggregate_failures do
          own_home = summary_list_question("Does your client own the home they live in?")
          expect(own_home).to have_answer("No")

          expect(page).not_to have_content("How much is your client's home worth?")
          expect(page).not_to have_content("Does your client own their home with anyone else?")
        end
      end
    end

    describe "vehicles" do
      it "renders the sub-heading" do
        expect(page).to have_css("h3", text: "Vehicles")
      end

      context "when the client owns a vehicle" do
        let(:own_vehicle) { true }

        let(:vehicle) do
          build(
            :vehicle,
            estimated_value: 1234,
            payment_remaining: 0,
            more_than_three_years_old: true,
            used_regularly: true,
          )
        end

        it "renders the vehicle details", :aggregate_failures do
          own_vehicle = summary_list_question("Does your client own a vehicle?")
          expect(own_vehicle).to have_answer("Yes")

          estimated_value = summary_list_question("What is the estimated value of the vehicle?")
          expect(estimated_value).to have_answer("£1,234")

          payment_remaining = summary_list_question("Are there any payments left on the vehicle?")
          expect(payment_remaining).to have_answer("£0")

          three_years_old = summary_list_question("The vehicle was bought more than three years ago?")
          expect(three_years_old).to have_answer("Yes")

          used_regularly = summary_list_question("Is the vehicle in regular use?")
          expect(used_regularly).to have_answer("Yes")
        end
      end

      context "when the client does not own a vehicle" do
        let(:own_vehicle) { false }

        it "does not render the vehicle details", :aggregate_failures do
          own_vehicle = summary_list_question("Does your client own a vehicle?")
          expect(own_vehicle).to have_answer("No")

          expect(page).not_to have_content("What is the estimated value of the vehicle?")
          expect(page).not_to have_content("Are there any payments left on the vehicle?")
          expect(page).not_to have_content("The vehicle was bought more than three years ago?")
          expect(page).not_to have_content("Is the vehicle in regular use?")
        end
      end
    end

    describe "bank accounts" do
      it "renders the sub-heading" do
        expect(page).to have_css("h2", text: "Which bank accounts does your client have?")
      end

      context "when the application is non-passported and the client gave open banking consent" do
        let(:bank_providers) { [build(:bank_provider, bank_accounts:)] }
        let(:bank_accounts) { [build(:bank_account, account_type: "TRANSACTION", balance: 1234)] }
        let(:savings_amount) { build(:savings_amount, offline_savings_accounts: 100) }

        it "renders online bank account details", :aggregate_failures do
          current_account = summary_list_question("Current account")
          expect(current_account).to have_answer("£1,234")

          savings_account = summary_list_question("Savings account")
          expect(savings_account).to have_answer("None declared")
        end

        it "renders offline bank account details", :aggregate_failures do
          offline_savings = summary_list_question("Has savings accounts they cannot access online")
          expect(offline_savings).to have_answer("Yes")

          offline_savings_amount = summary_list_question("Amount in offline savings accounts")
          expect(offline_savings_amount).to have_answer("£100")
        end
      end

      context "when the application is passported, or the client uploaded bank statements" do
        let(:legal_aid_application) do
          create(
            :legal_aid_application,
            :with_everything,
            :with_passported_state_machine,
            :with_cfe_v5_result,
            :with_proceedings,
            explicit_proceedings: %i[da006 da002],
            savings_amount: build(:savings_amount, offline_savings_accounts: 2345),
          )
        end

        it "renders the bank account details", :aggregate_failures do
          current_account = summary_list_question("Current account")
          expect(current_account).to have_answer("No")

          savings_account = summary_list_question("Savings account")
          expect(savings_account).to have_answer("£2,345")
        end
      end
    end

    describe "savings and investments" do
      let(:savings_amount) do
        build(
          :savings_amount,
          cash: 100,
          other_person_account: nil,
          national_savings: 1234,
          plc_shares: nil,
          peps_unit_trusts_capital_bonds_gov_stocks: 2345,
          life_assurance_endowment_policy: 3456,
        )
      end

      it "renders savings amounts", :aggregate_failures do
        cash = summary_list_question("Money not in a bank account")
        expect(cash).to have_answer("£100")

        other_person_account = summary_list_question("Access to another person's bank account")
        expect(other_person_account).to have_answer("No")

        national_savings = summary_list_question("ISAs, National Savings Certificates and Premium Bonds")
        expect(national_savings).to have_answer("£1,234")

        plc_shares = summary_list_question("Shares in a PLC")
        expect(plc_shares).to have_answer("No")

        peps_etc = summary_list_question("PEPs, unit trusts, capital bonds and government stocks")
        expect(peps_etc).to have_answer("£2,345")

        life_assurance = summary_list_question("Life assurance and endowment policies not linked to a mortgage")
        expect(life_assurance).to have_answer("£3,456")
      end
    end

    describe "other assets" do
      let(:other_assets_declaration) do
        build(
          :other_assets_declaration,
          timeshare_property_value: 100,
          land_value: nil,
          valuable_items_value: 1234,
          inherited_assets_value: 2345,
          money_owed_value: nil,
          trust_value: 5000,
          second_home_value: nil,
        )
      end

      it "renders other assets declarations", :aggregate_failures do
        timeshare = summary_list_question("Timeshare property")
        expect(timeshare).to have_answer("£100")

        land = summary_list_question("Land")
        expect(land).to have_answer("No")

        valuable_items = summary_list_question("Any valuable items worth £500 or more")
        expect(valuable_items).to have_answer("£1,234")

        inherited_assets = summary_list_question("Money or assets from the estate of a person who has died")
        expect(inherited_assets).to have_answer("£2,345")

        money_owed = summary_list_question("Money owed to them, including from a private mortgage")
        expect(money_owed).to have_answer("No")

        trust = summary_list_question("Interest in a trust")
        expect(trust).to have_answer("£5,000")

        second_home = summary_list_question("Second property or holiday home")
        expect(second_home).to have_answer("No")
      end
    end

    describe "restrictions" do
      context "when the client has their own capital" do
        let(:own_home) { "mortgage" }

        it "renders the sub-heading" do
          expect(page).to have_css("h2", text: "Restrictions on your client's assets")
        end
      end

      context "when the client does not have their own capital" do
        it "does not render the sub-heading" do
          expect(page).not_to have_css("h2", text: "Restrictions on your client's assets")
        end
      end
    end

    describe "policy disregards" do
      context "when the application has policy disregards" do
        let(:policy_disregards) do
          build(
            :policy_disregards,
            england_infected_blood_support: true,
            vaccine_damage_payments: false,
            variant_creutzfeldt_jakob_disease: false,
            criminal_injuries_compensation_scheme: true,
            national_emergencies_trust: false,
            we_love_manchester_emergency_fund: false,
            london_emergencies_trust: false,
          )
        end

        it "renders the sub-heading" do
          expect(page).to have_css("h2", text: "Payments from scheme or charities")
        end

        it "renders the policy disregards", :aggregate_failures do
          england_infected_blood_support = summary_list_question("England Infected Blood Support Scheme")
          expect(england_infected_blood_support).to have_answer("Yes")

          vaccine_damage_payments = summary_list_question("Vaccine Damage Payments Scheme")
          expect(vaccine_damage_payments).to have_answer("No")

          variant_creutzfeldt_jakob_disease = summary_list_question("Variant Creutzfeldt-Jakob disease (vCJD) Trust")
          expect(variant_creutzfeldt_jakob_disease).to have_answer("No")

          criminal_injuries_compensation_scheme = summary_list_question("Criminal Injuries Compensation Scheme")
          expect(criminal_injuries_compensation_scheme).to have_answer("Yes")

          national_emergencies_trust = summary_list_question("National Emergencies Trust (NET)")
          expect(national_emergencies_trust).to have_answer("No")

          we_love_manchester_emergency_fund = summary_list_question("We Love Manchester Emergency Fund")
          expect(we_love_manchester_emergency_fund).to have_answer("No")

          london_emergencies_trust = summary_list_question("The London Emergencies Trust")
          expect(london_emergencies_trust).to have_answer("No")
        end
      end

      context "when the application does not have policy disregards" do
        it "does not render the sub-heading" do
          expect(page).not_to have_css("h2", text: "Payments from scheme or charities")
        end
      end
    end
  end

  describe "bank statements" do
    context "when the legal aid application is uploading bank statements" do
      let(:permissions) { [build(:permission, :bank_statement_upload)] }
      let(:attachments) { [build(:attachment, :bank_statement, original_filename: "test.pdf")] }

      it "renders the sub-heading" do
        expect(page).to have_css("h3", text: "Bank statements")
      end

      it "renders the bank statements" do
        uploaded_bank_statements = summary_list_question("Uploaded bank statements")
        expect(uploaded_bank_statements).to have_answer("test.pdf")
      end
    end

    context "when the legal aid application is not uploading bank statements" do
      it "does not render the sub-heading" do
        expect(page).not_to have_css("h3", text: "Bank statements")
      end
    end
  end

private

  def summary_list_question(question)
    page.find(
      "dl.govuk-summary-list > div > dt.govuk-summary-list__key",
      text: question,
    )
  end

  def have_answer(answer)
    have_sibling("dd", class: "govuk-summary-list__value", text: answer)
  end

  def have_transaction_detail(type:, text:)
    have_css(
      "dl##{type}-details-questions > div.govuk-summary-list__row > dt",
      text:,
    )
  end

  def stub_manual_review_determiner(result:)
    allow(manual_review_determiner)
      .to receive(:manual_review_required?)
      .and_return(result)
  end

  def stub_cfe_result(attributes)
    attributes.each do |key, value|
      allow(cfe_result).to receive(key).and_return(value)
    end
  end

  def update_provider_permissions
    if permissions.any?
      legal_aid_application.provider.update!(permissions:)
    end
  end
end
