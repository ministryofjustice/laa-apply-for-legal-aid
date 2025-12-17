require "rails_helper"

RSpec.describe LegalAidApplication do
  let(:legal_aid_application) { create(:legal_aid_application) }

  # Main purpose: to ensure relationships to other objects set so that destroying application destroys all objects
  # that then become redundant.
  describe ".destroy_all" do
    subject(:destroy_all) { described_class.destroy_all }

    let!(:legal_aid_application) do
      create(:legal_aid_application,
             :with_everything,
             :with_multiple_proceedings_inc_section8,
             :with_negative_benefit_check_result,
             :with_bank_transactions,
             :with_chances_of_success)
    end

    before do
      create(:legal_aid_application_transaction_type, legal_aid_application:)
    end

    # A bit verbose, but minimises the SQL calls required to complete spec
    it "removes everything it needs to" do
      expect(BenefitCheckResult.count).not_to be_zero
      expect(OtherAssetsDeclaration.count).not_to be_zero
      expect(SavingsAmount.count).not_to be_zero
      expect(ApplicationMeritsTask::StatementOfCase.count).not_to be_zero
      expect(ProceedingMeritsTask::ChancesOfSuccess.count).not_to be_zero
      expect(Applicant.count).not_to be_zero
      expect(BankAccount.count).not_to be_zero
      expect(BankTransaction.count).not_to be_zero
      expect(BankProvider.count).not_to be_zero
      expect(BankAccountHolder.count).not_to be_zero
      expect(BankError.count).not_to be_zero
      expect(LegalAidApplicationTransactionType.count).not_to be_zero
      expect { destroy_all }.to change(described_class, :count).to(0)
      expect(BenefitCheckResult.count).to be_zero
      expect(OtherAssetsDeclaration.count).to be_zero
      expect(SavingsAmount.count).to be_zero
      expect(ApplicationMeritsTask::StatementOfCase.count).to be_zero
      expect(ProceedingMeritsTask::ChancesOfSuccess.count).to be_zero
      expect(Applicant.count).to be_zero
      expect(BankAccount.count).to be_zero
      expect(BankTransaction.count).to be_zero
      expect(BankProvider.count).to be_zero
      expect(BankAccountHolder.count).to be_zero
      expect(BankError.count).to be_zero
      expect(LegalAidApplicationTransactionType.count).to be_zero
    end

    it "leaves object it should not affect" do
      expect(TransactionType.count).not_to be_zero
      destroy_all
      expect(TransactionType.count).not_to be_zero
    end
  end

  describe ".search" do
    let!(:application_l123abc) { create(:legal_aid_application, application_ref: "L-123-ABC") }
    let(:jacob) { create(:applicant, first_name: "Jacob", last_name: "Rees-Mogg") }
    let!(:application_for_jacob) { create(:legal_aid_application, applicant: jacob) }
    let(:ccms_submission) { create(:submission, case_ccms_reference: "300000000009") }
    let!(:application_with_ccms) { create(:legal_aid_application, ccms_submission:) }

    it "matches application_ref" do
      [
        "L 123 ABC",
        "L123ABC",
        "l123abc",
        "L/123/ABC",
        "L123&ABC",
      ].each do |term|
        expect(described_class.search(term)).to include(application_l123abc), term
      end
      expect(described_class.search("something")).not_to include(application_l123abc)
    end

    it "matches applicant's name" do
      [
        "Rees-Mogg",
        "Jacob Rees-Mogg",
        "Jacob Rees'Mogg",
        "reesmogg",
        "smog",
        "cobree",
        "sMOg",
        "jac&ob",
      ].each do |term|
        expect(described_class.search(term)).to include(application_for_jacob), term
      end
      expect(described_class.search("something")).not_to include(application_for_jacob)
    end

    it "matches ccms case reference number" do
      [
        "300",
        "0",
        "9",
        "09",
        "0&9",
      ].each do |term|
        expect(described_class.search(term)).to include(application_with_ccms), term
      end
      expect(described_class.search("something")).not_to include(application_with_ccms)
    end
  end

  describe "#capture_policy_disregards?" do
    subject(:capture_policy_disregards) { legal_aid_application.capture_policy_disregards? }

    context "when calculation date is nil" do
      before { allow(legal_aid_application).to receive(:calculation_date).and_return(nil) }

      context "with today's date before start of policy disregards" do
        it "returns false" do
          travel_to Time.zone.local(2021, 1, 7, 13, 45)
          expect(capture_policy_disregards).to be false
          travel_back
        end
      end

      context "with today's date after start of policy disregards" do
        it "returns true" do
          travel_to Time.zone.local(2021, 1, 8, 13, 45)
          expect(capture_policy_disregards).to be true
          travel_back
        end
      end
    end

    context "with calculation date set" do
      before { allow(legal_aid_application).to receive(:calculation_date).and_return(calculation_date) }

      context "with today's date before start of policy disregards" do
        let(:calculation_date) { Date.new(2021, 1, 7) }

        it "returns false" do
          travel_to Time.zone.local(2021, 1, 7, 13, 45)
          expect(capture_policy_disregards).to be false
          travel_back
        end
      end

      context "with today's date after start of policy disregards" do
        let(:calculation_date) { Date.new(2021, 1, 8) }

        it "returns true" do
          travel_to Time.zone.local(2021, 1, 8, 13, 45)
          expect(capture_policy_disregards).to be true
          travel_back
        end
      end
    end
  end

  describe "#policy_disregards?" do
    context "with no policy disregard record" do
      it "returns false" do
        expect(legal_aid_application.policy_disregards).to be_nil
        expect(legal_aid_application.policy_disregards?).to be false
      end
    end

    context "when policy_disregards record exists" do
      context "when none selected is true" do
        before { create(:policy_disregards, legal_aid_application:) }

        it "returns false" do
          expect(legal_aid_application.policy_disregards?).to be false
        end
      end

      context "when none selected is false" do
        before { create(:policy_disregards, legal_aid_application:, national_emergencies_trust: true) }

        it "returns true" do
          expect(legal_aid_application.policy_disregards?).to be true
        end
      end
    end
  end

  describe "#capital_disregards?" do
    context "with no capital disregard record" do
      it "returns false" do
        expect(legal_aid_application.capital_disregards).to be_empty
        expect(legal_aid_application.capital_disregards?).to be false
      end
    end

    context "with capital_disregards record" do
      before { create(:capital_disregard, legal_aid_application:) }

      it "returns true" do
        expect(legal_aid_application.capital_disregards?).to be true
      end
    end
  end

  describe "#upsert_benefit_check_result" do
    subject(:upsert_benefit_check_result) { legal_aid_application.upsert_benefit_check_result }

    before do
      allow(BenefitCheckService).to receive(:call).with(legal_aid_application).and_return(benefit_check_response)
    end

    context "when benefit check service is working" do
      let(:benefit_check_response) do
        {
          benefit_checker_status: "Yes",
          confirmation_ref: "T1765791054660",
        }
      end

      it "creates a benefit_check_result with the right values" do
        expect { upsert_benefit_check_result }
          .to change { legal_aid_application.reload.benefit_check_result }
            .from(nil)
            .to(instance_of(BenefitCheckResult))

        expect(legal_aid_application.benefit_check_result)
          .to have_attributes(result: "Yes", dwp_ref: "T1765791054660")
      end
    end

    context "when benefit check service is down" do
      let(:benefit_check_response) { false }

      it "creates a benefit_check_result indicating failure, with the right values" do
        expect { upsert_benefit_check_result }
          .to change { legal_aid_application.reload.benefit_check_result }
            .from(nil)
            .to(instance_of(BenefitCheckResult))

        expect(legal_aid_application.benefit_check_result)
          .to have_attributes(result: "failure:no_response", dwp_ref: nil)
      end
    end

    context "when called twice" do
      before do
        create(:benefit_check_result, legal_aid_application:, dwp_ref: "old_ref", result: "Old result")
      end

      let(:benefit_check_response) do
        {
          benefit_checker_status: "New result",
          confirmation_ref: "new_ref",
        }
      end

      it "updates the benenfit_check_result" do
        expect { upsert_benefit_check_result }
          .to change { legal_aid_application.reload.benefit_check_result.attributes.symbolize_keys }
            .from(hash_including(dwp_ref: "old_ref", result: "Old result"))
            .to(hash_including(dwp_ref: "new_ref", result: "New result"))
      end
    end
  end

  describe "#benefit_check_status" do
    let(:benefit_check_response) do
      {
        benefit_checker_status:,
        confirmation_ref: SecureRandom.hex,
      }
    end

    before do
      legal_aid_application.save!
      allow(BenefitCheckService).to receive(:call).with(legal_aid_application).and_return(benefit_check_response)
      legal_aid_application.upsert_benefit_check_result
    end

    context "when the benefit check service returns a positive outcome" do
      let(:benefit_checker_status) { "Yes" }

      it { expect(legal_aid_application.benefit_check_status).to be :positive }
    end

    context "when the benefit check service returns a negative outcome" do
      let(:benefit_checker_status) { "No" }

      it { expect(legal_aid_application.benefit_check_status).to be :negative }
    end

    context "when the benefit check service returns an undetermined outcome" do
      let(:benefit_checker_status) { "Undetermined" }

      it { expect(legal_aid_application.benefit_check_status).to be :negative }
    end

    context "when benefit check service is down" do
      let(:benefit_check_response) { false }

      it { expect(legal_aid_application.benefit_check_status).to be :unsuccessful }
    end
  end

  describe "#lead_application_proceeding_type" do
    context "when application proceeding types exist" do
      let!(:legal_aid_application) do
        create(:legal_aid_application,
               :with_applicant,
               :with_proceedings,
               set_lead_proceeding: :da001,
               explicit_proceedings: %i[se014 da001])
      end
      let(:da001) { legal_aid_application.proceedings.find_by(ccms_code: "DA001") }
      let(:se014) { legal_aid_application.proceedings.find_by(ccms_code: "SE014") }

      it "returns the lead proceeding" do
        expect(legal_aid_application.lead_proceeding).to eq da001
      end
    end
  end

  describe "#pre_dwp_check?" do
    let(:state) { :initiated }
    let!(:legal_aid_application) { create(:legal_aid_application, :with_applicant, state) }

    context "when in pre-dwp-check state" do
      it "is true" do
        expect(legal_aid_application.pre_dwp_check?).to be true
      end
    end

    context "when in non-passported state" do
      let!(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine, :with_applicant, state) }
      let(:state) { :checking_non_passported_means }

      it "is false" do
        expect(legal_aid_application.pre_dwp_check?).to be false
      end
    end

    context "when in passported state" do
      let(:state) { :checking_passported_answers }

      it "is false" do
        expect(legal_aid_application.pre_dwp_check?).to be false
      end
    end
  end

  describe "#income_types?" do
    subject(:income_types?) { legal_aid_application.income_types? }

    context "when transaction type credits exist" do
      before do
        legal_aid_application.transaction_types << build(:transaction_type, :benefits)
      end

      it { is_expected.to be true }
    end

    context "when transaction type credits do not exist" do
      before do
        legal_aid_application.transaction_types = []
      end

      it { is_expected.to be false }
    end

    context "when housing benefit transaction type credits do exist" do
      before do
        legal_aid_application.transaction_types << build(:transaction_type, :housing_benefit)
      end

      it { is_expected.to be false }
    end
  end

  describe "#outgoing_types?" do
    context "when debit transaction types exist" do
      let(:rent_or_mortgage_debit) { create(:transaction_type, :rent_or_mortgage) }
      let(:legal_aid_application) { create(:legal_aid_application, transaction_types: [rent_or_mortgage_debit]) }

      it "returns true" do
        expect(legal_aid_application.reload.outgoing_types?).to be true
      end
    end

    context "when no debit transaction types exist" do
      let(:benefits_credit) { create(:transaction_type, :benefits) }
      let(:legal_aid_application) { create(:legal_aid_application, transaction_types: [benefits_credit]) }

      it "returns false" do
        expect(legal_aid_application.outgoing_types?).to be false
      end
    end
  end

  describe "#statement_of_case_uploaded?" do
    let(:legal_aid_application) { create(:legal_aid_application) }

    context "with statement of case files attached" do
      it "is true" do
        create(:statement_of_case, :with_original_file_attached, legal_aid_application:)
        expect(legal_aid_application.statement_of_case_uploaded?).to be true
      end
    end

    context "with no statement of case files attached" do
      it "is false" do
        expect(legal_aid_application.statement_of_case_uploaded?).to be false
      end
    end
  end

  describe "benefit_check_result_needs_updating?" do
    let!(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :at_entering_applicant_details) }
    let(:applicant) { legal_aid_application.applicant }

    context "with no benefit check result" do
      before { legal_aid_application.benefit_check_result&.destroy! }

      it "returns true" do
        expect(legal_aid_application).to be_benefit_check_result_needs_updating
      end
    end

    context "with a failed benefit check result" do
      before { create(:benefit_check_result, :failure, legal_aid_application:) }

      it "returns true" do
        expect(legal_aid_application).to be_benefit_check_result_needs_updating
      end
    end

    context "with up to date benefit check results" do
      before { create(:benefit_check_result, legal_aid_application:) }

      it "returns false" do
        expect(legal_aid_application).not_to be_benefit_check_result_needs_updating
      end

      context "but later, applicant first name updated" do
        before do
          applicant.update!(first_name: Faker::Name.first_name)
          travel(-10.minutes) { create(:benefit_check_result, legal_aid_application:) }
        end

        it "returns true" do
          expect(legal_aid_application).to be_benefit_check_result_needs_updating
        end
      end

      context "but later, state changes" do
        before do
          legal_aid_application.check_applicant_details!
        end

        it "returns false" do
          expect(legal_aid_application).not_to be_benefit_check_result_needs_updating
        end
      end
    end
  end

  describe "#generate_citizen_access_token!" do
    subject(:generate_citizen_access_token!) { legal_aid_application.generate_citizen_access_token! }

    let(:legal_aid_application) { create(:legal_aid_application) }

    before { allow(SecureRandom).to receive(:uuid).and_return("test-token") }

    it "generates a citizen URL access token" do
      expect(generate_citizen_access_token!).to have_attributes(
        token: "test-token",
        expires_on: 8.days.from_now.to_date,
        legal_aid_application:,
      )
    end
  end

  describe "state machine" do
    let(:legal_aid_application) { create(:legal_aid_application) }

    describe "#state" do
      it 'is created with a default state of "initiated"' do
        expect(legal_aid_application.state).to eq("initiated")
      end

      context "when advancing state" do
        it "advances state and saves" do
          expect { legal_aid_application.enter_applicant_details! }
            .to change(legal_aid_application, :state)
              .from("initiated")
              .to("entering_applicant_details")
        end
      end

      context "when loading an existing record and advancing state" do
        before { legal_aid_application.enter_applicant_details! }

        it "is in the expected state and can be advanced" do
          expect(legal_aid_application.state).to eq "entering_applicant_details"
          legal_aid_application.check_applicant_details!
          expect(legal_aid_application.state).to eq "checking_applicant_details"
        end
      end
    end

    describe "#find_or_create_state_machine" do
      context "without a state machine relation" do
        let(:legal_aid_application) { build(:legal_aid_application) }

        it "creates the default state_machine relation" do
          expect { legal_aid_application.find_or_create_state_machine }
            .to change(legal_aid_application, :state_machine)
              .from(nil)
              .to(instance_of(PassportedStateMachine))
        end
      end

      context "with an existing state machine relation" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine) }

        it "returns the state_machine relation" do
          expect { legal_aid_application.find_or_create_state_machine }
          .not_to change(legal_aid_application, :state_machine)
            .from(instance_of(NonPassportedStateMachine))
        end
      end
    end

    describe "#state_machine_proxy" do
      context "without a state machine relation" do
        let(:legal_aid_application) { build(:legal_aid_application) }

        it "creates the default state_machine relation" do
          expect { legal_aid_application.state_machine_proxy }
            .to change(legal_aid_application, :state_machine)
              .from(nil)
              .to(instance_of(PassportedStateMachine))
        end
      end

      context "with an existing state machine relation" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine) }

        it "returns the state_machine relation" do
          expect { legal_aid_application.state_machine_proxy }
          .not_to change(legal_aid_application, :state_machine)
            .from(instance_of(NonPassportedStateMachine))
        end
      end

      describe "#change_state_machine_type" do
        it "switches to the new state machine" do
          expect { legal_aid_application.change_state_machine_type("NonPassportedStateMachine") }
          .to change(legal_aid_application, :state_machine)
            .from(instance_of(PassportedStateMachine))
            .to(instance_of(NonPassportedStateMachine))
        end
      end

      describe "#after_create" do
        let(:legal_aid_application) { build(:legal_aid_application) }

        it "creates the default state_machine relation" do
          expect { legal_aid_application.save! }
            .to change(legal_aid_application, :state_machine)
              .from(nil)
              .to(instance_of(PassportedStateMachine))
        end
      end
    end
  end

  describe "#merits_complete!" do
    let!(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

    let(:date) { Date.new(2021, 1, 7) }

    it "updates the application merits_submitted_at attribute" do
      travel_to(date) do
        legal_aid_application.merits_complete!
        expect(legal_aid_application.reload.merits_submitted_at).to eq(date)
      end
    end
  end

  describe "#summary_state" do
    let!(:legal_aid_application) { create(:legal_aid_application, :with_applicant, merits_submitted_at:) }

    context "with merits not completed" do
      let(:merits_submitted_at) { nil }

      it "returns :in_progress summary state" do
        expect(legal_aid_application.summary_state).to eq(:in_progress)
      end
    end

    context "with merits completed" do
      let(:merits_submitted_at) { Faker::Time.backward }

      it "returns :in_progress summary state" do
        expect(legal_aid_application.summary_state).to eq(:submitted)
      end
    end
  end

  describe "#shared_ownership?" do
    subject(:legal_aid_application) { create(:legal_aid_application, shared_ownership: shared_ownership_reason) }

    context "when applicant owns a share of a property" do
      let(:shared_ownership_reason) { LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.first }

      it "return true that the applicant owns a share of a property" do
        expect(legal_aid_application.shared_ownership?).to be true
      end
    end

    context "when applicant is the sole owner of a property" do
      let(:shared_ownership_reason) { LegalAidApplication::SHARED_OWNERSHIP_NO_REASONS.first }

      it "return true that the applicant owns a share of a property" do
        expect(legal_aid_application.shared_ownership?).to be false
      end
    end
  end

  describe "#uncategorised_transactions?" do
    let(:applicant) { create(:applicant) }
    let(:bank_provider) { create(:bank_provider, applicant:) }
    let(:bank_account) { create(:bank_account, bank_provider:) }

    context "when transaction types have associated bank transactions" do
      let(:legal_aid_application) { create(:legal_aid_application, applicant:, transaction_types: [transaction_type]) }

      context "with income transactions" do
        let(:transaction_type) { create(:transaction_type, :credit) }

        it "returns false" do
          create(:bank_transaction, :credit, transaction_type:, bank_account:)
          expect(legal_aid_application.uncategorised_transactions?(:credit)).to be false
        end
      end

      context "with outgoing transactions" do
        let(:transaction_type) { create(:transaction_type, :debit) }

        it "returns false" do
          create(:bank_transaction, :debit, transaction_type:, bank_account:)
          expect(legal_aid_application.uncategorised_transactions?(:debit)).to be false
        end
      end
    end

    context "when transaction types do not have associated bank transactions" do
      let(:legal_aid_application) { create(:legal_aid_application, applicant:, transaction_types: [transaction_type]) }

      context "with income transactions" do
        let(:transaction_type) { create(:transaction_type, :credit) }

        it "returns true" do
          create(:bank_transaction, :credit, transaction_type: nil, bank_account:)
          expect(legal_aid_application.uncategorised_transactions?(:credit)).to be true
        end
      end

      context "with outgoing transactions" do
        let(:transaction_type) { create(:transaction_type, :debit) }

        it "returns true" do
          create(:bank_transaction, :debit, transaction_type: nil, bank_account:)
          expect(legal_aid_application.uncategorised_transactions?(:debit)).to be true
        end
      end
    end
  end

  describe "#own_home?" do
    context "when legal_aid_application.own_home is nil" do
      before { legal_aid_application.update!(own_home: nil) }

      it "returns false" do
        expect(legal_aid_application.own_home?).to be(false)
      end
    end

    context 'when legal_aid_application.own_home is "no"' do
      let(:legal_aid_application) { create(:legal_aid_application, :without_own_home) }

      it "returns false" do
        expect(legal_aid_application.own_home?).to be(false)
      end
    end

    context 'when legal_aid_application.own_home is not "no"' do
      let(:legal_aid_application) { create(:legal_aid_application, :with_own_home_mortgaged) }

      it "returns true" do
        expect(legal_aid_application.own_home?).to be(true)
      end
    end
  end

  describe "#own_capital?" do
    context "with no home, savings or assets" do
      let(:legal_aid_application) { create(:legal_aid_application, own_home: nil) }

      it "returns nil" do
        expect(legal_aid_application.own_capital?).to be false
      end
    end

    context "with own home" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_own_home_mortgaged) }

      it "returns true" do
        expect(legal_aid_application.own_capital?).to be(true)
      end
    end

    context "with some assets" do
      before { legal_aid_application.update!(other_assets_declaration: create(:other_assets_declaration, :with_all_values)) }

      it "returns true" do
        expect(legal_aid_application.own_capital?).to be(true)
      end
    end

    context "with some savings" do
      before { legal_aid_application.update!(savings_amount: create(:savings_amount, :with_values)) }

      it "returns true" do
        expect(legal_aid_application.own_capital?).to be(true)
      end
    end
  end

  describe "#set_transaction_period" do
    subject(:set_transaction_period) { legal_aid_application.set_transaction_period }

    it "sets start" do
      set_transaction_period
      expect(legal_aid_application.transaction_period_start_on).to eq(Date.current - 3.months)
    end

    it "sets finish" do
      set_transaction_period
      expect(legal_aid_application.transaction_period_finish_on).to eq(Date.current)
    end

    context "when delegated functions are used" do
      let!(:legal_aid_application) do
        create(:legal_aid_application,
               :with_proceedings,
               :with_delegated_functions_on_proceedings,
               explicit_proceedings: [:da004],
               set_lead_proceeding: :da004,
               df_options: { DA004: [used_delegated_functions_on, used_delegated_functions_reported_on] })
      end
      let(:proceedings) { legal_aid_application.proceedings }
      let!(:used_delegated_functions_reported_on) { Time.zone.today }
      let!(:used_delegated_functions_on) { Faker::Date.backward }

      it "sets start and finish relative to used_delegated_functions_on" do
        set_transaction_period
        expect(legal_aid_application.transaction_period_start_on).to eq(proceedings.first.used_delegated_functions_on - 3.months)
        expect(legal_aid_application.transaction_period_finish_on).to eq(proceedings.first.used_delegated_functions_on)
      end
    end
  end

  describe "#submitted_to_ccms?" do
    context "when application not submitted to ccms" do
      let(:legal_aid_application) { create(:legal_aid_application) }

      it "returns false" do
        expect(legal_aid_application.submitted_to_ccms?).to be(false)
      end
    end

    context "when application submitted to ccms" do
      let(:legal_aid_application) { create(:legal_aid_application, :submitted_to_ccms) }

      it "returns true" do
        expect(legal_aid_application.submitted_to_ccms?).to be(true)
      end
    end
  end

  describe "#read_only?" do
    context "when provider application not submitted" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine) }

      it "returns false" do
        expect(legal_aid_application.read_only?).to be(false)
      end
    end

    context "when provider submitted" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine, :applicant_entering_means) }

      it "returns true" do
        expect(legal_aid_application.read_only?).to be(true)
      end
    end

    context "when checking citizen answers?" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine, :checking_citizen_answers) }

      it "returns true" do
        expect(legal_aid_application.read_only?).to be(true)
      end
    end
  end

  describe "#applicant_details_checked!" do
    let(:legal_aid_application) { create(:legal_aid_application, :with_everything, :without_own_home, :checking_applicant_details) }

    it "transitions to applicant_details_checked" do
      expect { legal_aid_application.applicant_details_checked! }
        .to change { legal_aid_application.reload.state }
          .from("checking_applicant_details")
          .to("applicant_details_checked")
    end

    context "when transitioning from provider_entering_merits" do
      let(:legal_aid_application) { create(:legal_aid_application, :at_provider_entering_merits) }

      context "with non means tested application" do
        before { allow(legal_aid_application).to receive(:non_means_tested?).and_return(true) }

        it "transitions to applicant_details_checked" do
          expect { legal_aid_application.applicant_details_checked! }
            .to change { legal_aid_application.reload.state }
              .from("provider_entering_merits")
              .to("applicant_details_checked")
        end
      end

      context "with means tested application" do
        before { allow(legal_aid_application).to receive(:non_means_tested?).and_return(false) }

        it "raises AASM::InvalidTransition error" do
          expect { legal_aid_application.applicant_details_checked! }.to raise_error AASM::InvalidTransition
        end
      end
    end
  end

  describe "#create_app_ref" do
    it "generates an application_ref when the application is created" do
      legal_aid_application = described_class.create!(provider: create(:provider))
      expect(legal_aid_application.application_ref).to match(/L(-[ABCDEFHJKLMNPRTUVWXY0-9]{3}){2}/)
    end
  end

  describe "state label" do
    let(:states) { legal_aid_application.state_machine_proxy.aasm.states.map(&:name) }

    context "with passported states" do
      it "has a translation for all states" do
        states.each do |state|
          expect(I18n.exists?("enums.legal_aid_application.state.#{state}")).to be(true)
        end
      end
    end

    context "with non-passported states" do
      before { legal_aid_application.change_state_machine_type("NonPassportedStateMachine") }

      it "has a translation for all states" do
        states.each do |state|
          expect(I18n.exists?("enums.legal_aid_application.state.#{state}")).to be(true)
        end
      end
    end
  end

  describe "#used_delegated_functions?" do
    let!(:legal_aid_application) do
      create(:legal_aid_application,
             :with_proceedings,
             :with_delegated_functions_on_proceedings,
             explicit_proceedings: [:da004],
             set_lead_proceeding: :da004,
             df_options: { DA004: [Time.zone.now, Time.zone.now] })
    end

    context "when delegated functions used" do
      it "returns true" do
        expect(legal_aid_application.used_delegated_functions?).to be true
      end
    end

    context "when delegated functions not used" do
      let!(:legal_aid_application) { create(:legal_aid_application, :with_proceedings) }

      it "returns false" do
        expect(legal_aid_application.used_delegated_functions?).to be false
      end
    end
  end

  describe "#earliest_delegated_functions_date" do
    let(:laa) { create(:legal_aid_application) }

    before do
      create(:proceeding, :se014, legal_aid_application: laa)
      create(:proceeding, :da001, legal_aid_application: laa, used_delegated_functions: true, used_delegated_functions_on: date1)
      create(:proceeding, :se013, legal_aid_application: laa, used_delegated_functions: true, used_delegated_functions_on: date2)
    end

    context "when there are application_proceeding_type records with dates" do
      let(:date1) { Time.zone.today }
      let(:date2) { Time.zone.yesterday }

      it "returns 2 records with DF dates, in date order" do
        expect(laa.reload.earliest_delegated_functions_date).to eq Date.yesterday
      end
    end

    context "with no delegated_functions dates" do
      let(:date1) { nil }
      let(:date2) { nil }

      it "returns nil" do
        expect(laa.earliest_delegated_functions_date).to be_nil
      end
    end
  end

  describe "#default_cost_limitations" do
    context "when substantive" do
      let(:application) { create(:legal_aid_application, :with_proceedings, set_lead_proceeding: :da001) }

      it "returns the substantive cost limitation for the first proceeding type" do
        expect(application.default_cost_limitation).to eq 25_000.0
      end
    end

    context "with delegated functions" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, proceeding_count: 4, set_lead_proceeding: :da004) }
      let(:da004) { legal_aid_application.proceedings.find_by(ccms_code: "DA004") }

      it "returns the substantive cost limitation for the proceeding" do
        create(:chances_of_success, :with_optional_text, proceeding: da004)
        expect(legal_aid_application.default_cost_limitation).to eq 25_000.0
      end
    end

    context "when the lead application has a smaller substantive cost limit" do
      let(:legal_aid_application) { create(:legal_aid_application) }

      before do
        create(:proceeding, :da006, legal_aid_application:, substantive_cost_limitation: 5_000, lead_proceeding: true)
        create(:proceeding, :se013, legal_aid_application:)
      end

      it "takes the largest cost value" do
        expect(legal_aid_application.default_cost_limitation).to eq 25_000.0
      end
    end
  end

  describe "#substantive_cost_limitation" do
    subject(:substantive_cost_limitation) { legal_aid_application.substantive_cost_limitation }

    let(:legal_aid_application) { create(:legal_aid_application) }

    before do
      create(:proceeding, :da006, legal_aid_application:, substantive_cost_limitation: 5_000, lead_proceeding: true)
      create(:proceeding, :se013, legal_aid_application:, substantive_cost_limitation: 10_000)
    end

    context "when the provider accepts the default" do
      it { is_expected.to eq 10_000 }
    end

    context "when the provider has overridden a smaller default" do
      let(:legal_aid_application) do
        create(:legal_aid_application,
               substantive_cost_override: true,
               substantive_cost_requested: 12_000,
               substantive_cost_reasons: "something... something... reasons")
      end

      it { is_expected.to eq 12_000 }
    end

    context "when the application is is an associated family linked application" do
      let(:lead_application) { create(:legal_aid_application) }

      before { create(:linked_application, lead_application:, associated_application: legal_aid_application, link_type_code: "FC_LEAD") }

      it { is_expected.to eq 0 }
    end
  end

  describe "#default_delegated_functions_cost_limitation" do
    subject(:default_delegated_functions_cost_limitation) { legal_aid_application.default_delegated_functions_cost_limitation }

    before do
      create(:proceeding, :da006, legal_aid_application:, delegated_functions_cost_limitation: 5_000, lead_proceeding: true)
      create(:proceeding, :se013, legal_aid_application:, delegated_functions_cost_limitation: 10_000)
    end

    it { is_expected.to eq 5_000 }

    context "when the application is is an associated family linked application" do
      let(:lead_application) { create(:legal_aid_application) }

      before { create(:linked_application, lead_application:, associated_application: legal_aid_application, link_type_code: "FC_LEAD") }

      it { is_expected.to eq 0 }
    end
  end

  describe "#additional_family_lead_delegated_functions_cost_limitation" do
    subject(:additional_family_lead_delegated_functions_cost_limitation) { legal_aid_application.additional_family_lead_delegated_functions_cost_limitation }

    before do
      create(:proceeding, :da006, legal_aid_application:, delegated_functions_cost_limitation: 5_000, lead_proceeding: true)
      create(:proceeding, :se013, legal_aid_application:, delegated_functions_cost_limitation: 10_000)
    end

    it { is_expected.to eq 2_500 }

    context "when the application is is an associated family linked application" do
      let(:lead_application) { create(:legal_aid_application) }

      before { create(:linked_application, lead_application:, associated_application: legal_aid_application, link_type_code: "FC_LEAD") }

      it { is_expected.to eq 0 }
    end
  end

  describe "#family_linked_associated_application?" do
    subject(:family_linked_associated_application?) { legal_aid_application.family_linked_associated_application? }

    let(:lead_application) { create(:legal_aid_application) }

    context "when the application does not have a lead application" do
      it { is_expected.to be false }
    end

    context "when the application has been legal linked" do
      before { create(:linked_application, lead_application:, associated_application: legal_aid_application, link_type_code: "LEGAL") }

      it { is_expected.to be false }
    end

    context "when the application has been family linked" do
      before { create(:linked_application, lead_application:, associated_application: legal_aid_application, link_type_code: "FC_LEAD") }

      it { is_expected.to be true }
    end
  end

  describe "#family_linked_lead_or_associated" do
    subject(:family_linked_lead_or_associated) { legal_aid_application.family_linked_lead_or_associated }

    let(:linked_application) { create(:legal_aid_application) }

    context "when the application does not have a lead application" do
      it { is_expected.to be_nil }
    end

    context "when the application is a lead legal_linked application" do
      before { create(:linked_application, lead_application: legal_aid_application, associated_application: linked_application, link_type_code: "LEGAL", confirm_link: true) }

      it { is_expected.to be_nil }
    end

    context "when the application is a lead family_linked application" do
      before { create(:linked_application, lead_application: legal_aid_application, associated_application: linked_application, link_type_code: "FC_LEAD", confirm_link: true) }

      it { is_expected.to eq "Lead" }
    end

    context "when the application is an associated family_linked application" do
      before { create(:linked_application, lead_application: linked_application, associated_application: legal_aid_application, link_type_code: "FC_LEAD", confirm_link: true) }

      it { is_expected.to eq "Associated" }
    end
  end

  describe "#legal_linked_lead_or_associated" do
    subject(:legal_linked_lead_or_associated) { legal_aid_application.legal_linked_lead_or_associated }

    let(:linked_application) { create(:legal_aid_application) }

    context "when the application does not have a lead application" do
      it { is_expected.to be_nil }
    end

    context "when the application is a lead family_linked application" do
      before { create(:linked_application, lead_application: legal_aid_application, associated_application: linked_application, link_type_code: "FC_LEAD", confirm_link: true) }

      it { is_expected.to be_nil }
    end

    context "when the application is a lead legal_linked application" do
      before { create(:linked_application, lead_application: legal_aid_application, associated_application: linked_application, link_type_code: "LEGAL", confirm_link: true) }

      it { is_expected.to eq "Lead" }
    end

    context "when the application is an associated legal_linked application" do
      before { create(:linked_application, lead_application: linked_application, associated_application: legal_aid_application, link_type_code: "LEGAL", confirm_link: true) }

      it { is_expected.to eq "Associated" }
    end
  end

  describe "#family_linked_applications_count" do
    subject(:family_linked_applications_count) { legal_aid_application.family_linked_applications_count }

    let(:linked_application) { create(:legal_aid_application) }

    context "when the application is not linked" do
      it { is_expected.to be_nil }
    end

    context "when the application has been legal linked" do
      before { create(:linked_application, lead_application: legal_aid_application, associated_application: linked_application, link_type_code: "LEGAL", confirm_link: true) }

      it { is_expected.to be_nil }
    end

    context "when the application is a lead application with two associated family linked applications" do
      let(:another_linked_application) { create(:legal_aid_application) }

      before do
        create(:linked_application, lead_application: legal_aid_application, associated_application: linked_application, link_type_code: "FC_LEAD", confirm_link: true)
        create(:linked_application, lead_application: legal_aid_application, associated_application: another_linked_application, link_type_code: "FC_LEAD", confirm_link: true)
      end

      it { is_expected.to eq 3 }
    end

    context "when the application is an associated family linked application" do
      before do
        create(:linked_application, lead_application: linked_application, associated_application: legal_aid_application, link_type_code: "FC_LEAD", confirm_link: true)
      end

      it { is_expected.to be_nil }
    end
  end

  describe "#legal_linked_applications_count" do
    subject(:legal_linked_applications_count) { legal_aid_application.legal_linked_applications_count }

    let(:linked_application) { create(:legal_aid_application) }

    context "when the application is not linked" do
      it { is_expected.to be_nil }
    end

    context "when the application has been family linked" do
      before { create(:linked_application, lead_application: legal_aid_application, associated_application: linked_application, link_type_code: "FC_LEAD", confirm_link: true) }

      it { is_expected.to be_nil }
    end

    context "when the application is a lead application with two associated legal linked applications" do
      let(:another_linked_application) { create(:legal_aid_application) }

      before do
        create(:linked_application, lead_application: legal_aid_application, associated_application: linked_application, link_type_code: "LEGAL", confirm_link: true)
        create(:linked_application, lead_application: legal_aid_application, associated_application: another_linked_application, link_type_code: "LEGAL", confirm_link: true)
      end

      it { is_expected.to eq 3 }
    end

    context "when the application an associated legal linked application" do
      before do
        create(:linked_application, lead_application: linked_application, associated_application: legal_aid_application, link_type_code: "LEGAL", confirm_link: true)
      end

      it { is_expected.to be_nil }
    end
  end

  describe "associated_family_linked_application?" do
    subject(:legal_linked_applications_count) { legal_aid_application.associated_family_linked_application? }

    let(:linked_application) { create(:legal_aid_application) }
    let(:confirm_link) { true }

    before do
      create(:linked_application, lead_application: linked_application, associated_application: legal_aid_application, link_type_code: "FC_LEAD", confirm_link:)
    end

    context "when the family link has been confirmed" do
      it { is_expected.to be true }
    end

    context "when the family link has not been confirmed" do
      let(:confirm_link) { false }

      it { is_expected.to be false }
    end
  end

  describe "#bank_transactions" do
    subject(:bank_transactions) { legal_aid_application.bank_transactions }

    let(:transaction_period_start_on) { "2019-08-10".to_date }
    let(:transaction_period_finish_on) { "2019-08-20".to_date }
    let(:date_before_start) { Time.zone.parse("2019-08-09 23:40 +0100") }
    let(:date_after_start)  { Time.zone.parse("2019-08-10 00:20 +0100") }
    let(:date_before_end)   { Time.zone.parse("2019-08-20 23:40 +0100") }
    let(:date_after_end)    { Time.zone.parse("2019-08-21 00:20 +0100") }
    let(:legal_aid_application) do
      create(:legal_aid_application,
             :with_applicant,
             transaction_period_start_on:,
             transaction_period_finish_on:)
    end
    let(:bank_provider) { create(:bank_provider, applicant: legal_aid_application.applicant) }
    let(:bank_account) { create(:bank_account, bank_provider:) }
    let!(:transaction_before_start) { create(:bank_transaction, bank_account:, happened_at: date_before_start) }
    let!(:transaction_after_start) { create(:bank_transaction, bank_account:, happened_at: date_after_start) }
    let!(:transaction_before_end) { create(:bank_transaction, bank_account:, happened_at: date_before_end) }
    let!(:transaction_after_end) { create(:bank_transaction, bank_account:, happened_at: date_after_end) }
    let(:transaction_ids) { bank_transactions.pluck(:id) }

    it "returns the all transactions" do
      expect(transaction_ids).to include(transaction_after_start.id)
      expect(transaction_ids).to include(transaction_before_end.id)
      expect(transaction_ids).to include(transaction_before_start.id)
      expect(transaction_ids).to include(transaction_after_end.id)
    end
  end

  describe "#applicant_receives_benefit?" do
    subject(:applicant_receives_benefit?) { legal_aid_application.applicant_receives_benefit? }

    context "when benefit_check_result exists?" do
      context "with postive result" do
        before { build(:benefit_check_result, :positive, legal_aid_application:) }

        context "with no DWP Override" do
          it { expect(applicant_receives_benefit?).to be true }
        end

        context "with DWP Override" do
          before { build(:dwp_override, legal_aid_application:) }

          it { expect(applicant_receives_benefit?).to be true }
        end
      end

      context "with negative result" do
        before { build(:benefit_check_result, :negative, legal_aid_application:) }

        context "with no DWP override" do
          it { expect(applicant_receives_benefit?).to be false }
        end

        context "with DWP Override" do
          context "when the provider selects yes for evidence" do
            before { build(:dwp_override, :with_evidence, legal_aid_application:) }

            it { expect(applicant_receives_benefit?).to be true }
          end

          context "when the provider selects no for evidence" do
            before { build(:dwp_override, :with_no_evidence, legal_aid_application:) }

            it { expect(applicant_receives_benefit?).to be false }
          end
        end
      end

      context "with undetermined result" do
        before { build(:benefit_check_result, :undetermined, legal_aid_application:) }

        context "with no DWP Override" do
          it { expect(applicant_receives_benefit?).to be false }
        end

        context "with DWP Override" do
          before { build(:dwp_override, :with_evidence, legal_aid_application:) }

          it { expect(applicant_receives_benefit?).to be true }
        end
      end

      context "with skipped result" do
        before { build(:benefit_check_result, :skipped, legal_aid_application:) }

        it { expect(applicant_receives_benefit?).to be false }
      end
    end

    context "when benefit_check_result does not exist" do
      it { expect(applicant_receives_benefit?).to be false }
    end
  end

  describe "#passported?" do
    it "is alias of #applicant_receives_benefit?" do
      expect(legal_aid_application.method(:passported?)).to eql(legal_aid_application.method(:applicant_receives_benefit?))
    end
  end

  describe "#non_passported?" do
    subject(:non_passported?) { legal_aid_application.non_passported? }

    context "when benefit_check_result exists?" do
      context "with postive result" do
        before { build(:benefit_check_result, :positive, legal_aid_application:) }

        context "with no DWP Override" do
          it { expect(non_passported?).to be false }
        end

        context "with DWP Override" do
          before { build(:dwp_override, legal_aid_application:) }

          it { expect(non_passported?).to be false }
        end
      end

      context "with negative result" do
        before { build(:benefit_check_result, :negative, legal_aid_application:) }

        context "with no DWP override" do
          it { expect(non_passported?).to be true }
        end

        context "with DWP Override" do
          context "when the provider selects yes for evidence" do
            before { build(:dwp_override, :with_evidence, legal_aid_application:) }

            it { expect(non_passported?).to be false }
          end

          context "when the provider selects no for evidence" do
            before { build(:dwp_override, :with_no_evidence, legal_aid_application:) }

            it { expect(non_passported?).to be true }
          end
        end
      end

      context "with undetermined result" do
        before { build(:benefit_check_result, :undetermined, legal_aid_application:) }

        context "with no DWP Override" do
          it { expect(non_passported?).to be true }
        end

        context "with DWP Override" do
          before { build(:dwp_override, :with_evidence, legal_aid_application:) }

          it { expect(non_passported?).to be false }
        end
      end

      context "with skipped result" do
        before { build(:benefit_check_result, :skipped, legal_aid_application:) }

        it { expect(non_passported?).to be true }
      end
    end

    context "without benefit_check_result" do
      before { legal_aid_application.benefit_check_result&.destroy }

      it { expect(non_passported?).to be true }
    end

    context "when non-means-tested application" do
      let(:legal_aid_application) { build(:legal_aid_application, applicant:) }
      let(:applicant) { build(:applicant, age_for_means_test_purposes: 17) }

      context "with positive benefit_check_result" do
        before { build(:benefit_check_result, :positive, legal_aid_application:) }

        it { expect(non_passported?).to be false }
      end

      context "with negative benefit_check_result" do
        before { build(:benefit_check_result, :negative, legal_aid_application:) }

        it { expect(non_passported?).to be false }
      end

      context "with undetermined benefit_check_result" do
        before { build(:benefit_check_result, :undetermined, legal_aid_application:) }

        it { expect(non_passported?).to be false }
      end

      context "without benefit_check_result" do
        before { legal_aid_application.benefit_check_result&.destroy }

        it { expect(non_passported?).to be false }
      end

      context "with skipped benefit_check_result" do
        before { build(:benefit_check_result, :skipped, legal_aid_application:) }

        it { expect(non_passported?).to be false }
      end
    end
  end

  describe "#non_means_tested?" do
    subject { legal_aid_application.non_means_tested? }

    let(:legal_aid_application) { build(:legal_aid_application, applicant:) }

    context "with applicant age of 17" do
      let(:applicant) { build(:applicant, age_for_means_test_purposes: 17) }

      it { is_expected.to be true }
    end

    context "with applicant age of 18" do
      let(:applicant) { build(:applicant, age_for_means_test_purposes: 18) }

      it { is_expected.to be false }
    end

    context "with applicant age of nil" do
      let(:applicant) { build(:applicant, age_for_means_test_purposes: nil) }

      it { is_expected.to be false }
    end
  end

  describe "#under_18?" do
    subject { legal_aid_application.under_18? }

    let(:legal_aid_application) { build(:legal_aid_application, applicant:) }

    context "with applicant age of 17 for means test purposes" do
      let(:applicant) { build(:applicant, age_for_means_test_purposes: 17) }

      it { is_expected.to be true }
    end

    context "with applicant age of 18 for means test purposes" do
      let(:applicant) { build(:applicant, age_for_means_test_purposes: 18) }

      it { is_expected.to be false }
    end

    context "with applicant age of nil" do
      let(:applicant) { build(:applicant, age_for_means_test_purposes: nil) }

      it { is_expected.to be false }
    end
  end

  describe "#generated_reports" do
    let(:legal_aid_application) { create(:legal_aid_application, :generating_reports) }
    let(:submit_applications_to_ccms) { true }

    before { allow(Rails.configuration.x.ccms_soa).to receive(:submit_applications_to_ccms).and_return(submit_applications_to_ccms) }

    it "starts the ccms submission process" do
      expect(legal_aid_application.find_or_create_ccms_submission).to receive(:process_async!)
      legal_aid_application.generated_reports!
    end

    context "when submit_applications_to_ccms is set to false" do
      let(:submit_applications_to_ccms) { false }

      it "does not start the ccms submission process" do
        expect(legal_aid_application.find_or_create_ccms_submission).not_to receive(:process_async!)
        legal_aid_application.generated_reports!
      end
    end
  end

  describe "#submitted_assessment" do
    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :checking_merits_answers) }
    let(:feedback_url) { "http://test/feedback/new" }

    before { allow(Rails.configuration.x.ccms_soa).to receive(:submit_applications_to_ccms).and_return(true) }

    it "schedules a PostSubmissionProcessingJob" do
      expect(PostSubmissionProcessingJob).to receive(:perform_later).with(
        legal_aid_application.id,
        feedback_url,
      ).and_call_original
      legal_aid_application.generate_reports!
    end
  end

  describe "#complete_non_passported_means!" do
    let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine, :checking_citizen_answers) }

    it "runs the complete means service and the bank transaction analyser" do
      expect(BankTransactionsAnalyserJob).to receive(:perform_later).with(legal_aid_application)
      legal_aid_application.complete_non_passported_means!
    end
  end

  describe "#cfe_result" do
    it "returns the result associated with the most recent CFE::Submission" do
      travel(-10.minutes) do
        legal_aid_application = create(:legal_aid_application)
        submission1 = create(:cfe_submission, legal_aid_application:)
        create(:cfe_v3_result, submission: submission1)
      end
      submission2 = create(:cfe_submission, legal_aid_application:)
      result2 = create(:cfe_v3_result, submission: submission2)

      expect(legal_aid_application.cfe_result).to eq result2
    end
  end

  describe "#transaction_types" do
    let(:legal_aid_application) { create(:legal_aid_application) }
    let!(:ff) { create(:transaction_type, :friends_or_family) }
    let!(:maintenance) { create(:transaction_type, :maintenance_out) }

    before { create(:legal_aid_application_transaction_type, transaction_type: maintenance, legal_aid_application:) }

    it "returns an array of transaction type records" do
      create(:legal_aid_application_transaction_type, transaction_type: ff, legal_aid_application:)
      expect(legal_aid_application.transaction_types).to eq [ff, maintenance]
    end

    describe "#transaction_type.for_outgoing_type?" do
      context "when there is no legal aid transaction type of the required type" do
        it "returns false" do
          expect(legal_aid_application.transaction_types.for_outgoing_type?("child_care")).to be false
        end
      end

      context "when there is a legal aid transaction type of the required type" do
        it "returns true" do
          expect(legal_aid_application.transaction_types.for_outgoing_type?("maintenance_out")).to be true
        end
      end
    end
  end

  describe "#parent_transaction_types" do
    before { Populators::TransactionTypePopulator.call }

    let(:benefits) { TransactionType.find_by(name: "benefits") }
    let(:excluded_benefits) { TransactionType.find_by(name: "excluded_benefits") }
    let(:pension) { TransactionType.find_by(name: "pension") }

    context "with legal aid application parent, child and stand-alone transaction types" do
      before do
        create(:legal_aid_application_transaction_type, legal_aid_application:, transaction_type: pension)
        create(:legal_aid_application_transaction_type, legal_aid_application:, transaction_type: benefits)
        create(:legal_aid_application_transaction_type, legal_aid_application:, transaction_type: excluded_benefits)
      end

      it "returns parent and stand-alone" do
        expect(legal_aid_application.parent_transaction_types).to contain_exactly(pension, benefits)
      end
    end

    context "with legal aid application child and stand-alone transaction types" do
      before do
        create(:legal_aid_application_transaction_type, legal_aid_application:, transaction_type: pension)
        create(:legal_aid_application_transaction_type, legal_aid_application:, transaction_type: excluded_benefits)
      end

      it "returns parent and stand-alone" do
        expect(legal_aid_application.parent_transaction_types).to contain_exactly(pension, benefits)
      end
    end

    context "with legal aid application parent and stand-alone transaction types" do
      before do
        create(:legal_aid_application_transaction_type, legal_aid_application:, transaction_type: pension)
        create(:legal_aid_application_transaction_type, legal_aid_application:, transaction_type: benefits)
      end

      it "returns parent and stand-alone" do
        expect(legal_aid_application.parent_transaction_types).to contain_exactly(pension, benefits)
      end
    end
  end

  describe "#provider_assessing_means?" do
    context "with delegated state machine methods" do
      let(:application) { create(:legal_aid_application, :with_passported_state_machine) }

      it "returns false" do
        expect(application.provider_assessing_means?).to be false
      end
    end
  end

  describe "#year_to_calculation_date" do
    let(:calc_date) { Date.new(2021, 2, 28) }
    let(:expected_start_date) { Date.new(2020, 2, 29) }

    it "returns two dates a year up to the calculation date" do
      allow(legal_aid_application).to receive(:calculation_date).and_return(calc_date)
      expect(legal_aid_application.year_to_calculation_date).to eq [expected_start_date, calc_date]
    end
  end

  describe "#chances of success" do
    let(:laa) { create(:legal_aid_application, :with_proceedings, proceeding_count: 4) }
    let(:proceeding_da001) { laa.proceedings.detect { |p| p.ccms_code == "DA001" } }
    let(:proceeding_se014) { laa.proceedings.detect { |p| p.ccms_code == "SE014" } }

    it "returns an array of all the chances of success records" do
      cos_da001 = create(:chances_of_success, proceeding: proceeding_da001)
      cos_se014 = create(:chances_of_success, proceeding: proceeding_se014)

      expect(laa.chances_of_success).to contain_exactly(cos_da001, cos_se014)
    end
  end

  describe "#attempts_to_settle" do
    let(:laa) { create(:legal_aid_application, :with_proceedings, proceeding_count: 4) }
    let(:proceeding_da001) { laa.proceedings.detect { |p| p.ccms_code == "DA001" } }
    let(:proceeding_se014) { laa.proceedings.detect { |p| p.ccms_code == "SE014" } }

    it "returns an array of attempt_to_settle records attached to the application" do
      ats_da001 = create(:attempts_to_settles, proceeding: proceeding_da001)
      ats_se014 = create(:attempts_to_settles, proceeding: proceeding_se014)

      expect(laa.attempts_to_settles).to contain_exactly(ats_da001, ats_se014)
    end
  end

  describe "#lead_proceeding" do
    let(:laa) { create(:legal_aid_application, :with_proceedings, proceeding_count: 4, set_lead_proceeding: :da004) }
    let(:proceeding_da004) { laa.proceedings.detect { |p| p.ccms_code == "DA004" } }

    it "returns the domestic abuse proceeding" do
      expect(laa.lead_proceeding).to eq proceeding_da004
    end
  end

  describe "#proceedings_by_name" do
    subject(:proceedings_by_name) { laa.proceedings_by_name }

    let(:laa) { create(:legal_aid_application) }

    before do
      laa.proceedings << create(:proceeding, :se013)
      laa.proceedings << create(:proceeding, :se014)
      laa.proceedings << create(:proceeding, :da004)
    end

    it "returns an array of three items" do
      expect(proceedings_by_name.size).to eq 3
    end

    it "returns se013 as the first item" do
      item = proceedings_by_name.first
      expect(item).to be_an_instance_of(LegalAidApplication::ProceedingStruct)
      expect(item.name).to eq "child_arrangements_order_contact"
      expect(item.meaning).to eq "Child arrangements order (contact)"
      expect(item.proceeding).to be_instance_of(Proceeding)
    end

    it "returns da004 as the last item" do
      item = proceedings_by_name.last
      expect(item).to be_an_instance_of(LegalAidApplication::ProceedingStruct)
      expect(item.name).to eq "nonmolestation_order"
      expect(item.meaning).to eq "Non-molestation order"
      expect(item.proceeding).to be_instance_of(Proceeding)
    end
  end

  describe "lowest_chances_of_success" do
    it "returns text representation of the lowest chance of success" do
      laa = create(:legal_aid_application, :with_proceedings, proceeding_count: 3)
      prospects = %w[likely borderline marginal]
      laa.proceedings.each_with_index do |proceeding, i|
        proceeding.chances_of_success = create(:chances_of_success, proceeding:,
                                                                    success_prospect: prospects[i])
      end
      expect(laa.lowest_prospect_of_success).to eq "Borderline"
    end
  end

  describe "#allowed_document_categories" do
    let(:laa) { create(:legal_aid_application) }

    before { allow(DocumentCategory).to receive(:displayable_document_category_names).and_return %w[benefit_evidence gateway_evidence] }

    it "defaults to an empty array" do
      expect(laa.allowed_document_categories).to eq []
    end

    it "allows a valid document category to be added" do
      laa.allowed_document_categories << "benefit_evidence"
      laa.save!
      expect(laa.allowed_document_categories).to eq %w[benefit_evidence]
    end

    it "allows multiple valid document categories to be added" do
      laa.allowed_document_categories = %w[gateway_evidence benefit_evidence]
      laa.save!
      expect(laa.allowed_document_categories).to eq %w[gateway_evidence benefit_evidence]
    end

    it "errors when an invalid document category is added" do
      laa.allowed_document_categories << "invalid_evidence"
      expect { laa.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "#section_8_proceedings?" do
    context "with section 8 proceedings" do
      let(:laa) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }

      it "returns true" do
        expect(laa.section_8_proceedings?).to be true
      end
    end

    context "without section 8 proceedings" do
      let(:laa) { create(:legal_aid_application) }

      it "returns false" do
        create(:proceeding, :da001, legal_aid_application: laa)
        expect(laa.section_8_proceedings?).to be false
      end
    end
  end

  describe "#special_children_act_proceedings?" do
    context "with special children act proceedings" do
      let(:laa) { create(:legal_aid_application, :with_multiple_sca_proceedings) }

      it "returns true" do
        expect(laa.special_children_act_proceedings?).to be true
      end
    end

    context "without special children act proceedings" do
      let(:laa) { create(:legal_aid_application) }

      it "returns false" do
        create(:proceeding, :da001, legal_aid_application: laa)
        expect(laa.special_children_act_proceedings?).to be false
      end
    end
  end

  describe "#public_law_family_proceedings?" do
    context "with public law family proceedings" do
      let(:laa) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[pbm32], set_lead_proceeding: :pbm32) }

      it "returns true" do
        expect(laa.public_law_family_proceedings?).to be true
      end
    end

    context "without public law family proceedings" do
      let(:laa) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001], set_lead_proceeding: :da001) }

      it "returns false" do
        expect(laa.public_law_family_proceedings?).to be false
      end
    end
  end

  describe "#plf_non_means_tested_proceeding?" do
    context "with a plf non means tested proceeding" do
      let(:laa) do
        create(:legal_aid_application,
               :with_proceedings,
               explicit_proceedings: %i[pbm40],
               set_lead_proceeding: :pbm40)
      end

      it "returns true" do
        expect(laa.plf_non_means_tested_proceeding?).to be true
      end
    end

    context "without special children act proceedings" do
      let(:laa) { create(:legal_aid_application) }

      it "returns false" do
        create(:proceeding, :da001, legal_aid_application: laa)
        expect(laa.plf_non_means_tested_proceeding?).to be false
      end
    end
  end

  describe "#online_current_accounts_balance" do
    let(:laa) { create(:legal_aid_application, :with_applicant) }

    context "with no current accounts" do
      it "returns nil" do
        expect(laa.online_current_accounts_balance).to be_nil
      end
    end

    context "with bank accounts" do
      let(:balance1) { BigDecimal(rand(1...1_000_000.0), 2) }
      let(:balance2) { BigDecimal(rand(1...1_000_000.0), 2) }
      let(:bank_provider) { create(:bank_provider, applicant: laa.applicant) }

      before do
        create(:bank_account, bank_provider:, account_type:, balance: balance1)
        create(:bank_account, bank_provider:, account_type:, balance: balance2)
      end

      context "with only savings" do
        let(:account_type) { "SAVINGS" }

        it "returns nil" do
          expect(laa.online_current_accounts_balance).to be_nil
        end
      end

      context "with only current" do
        let(:account_type) { "TRANSACTION" }

        it "returns the sum of the balances" do
          expect(laa.online_current_accounts_balance).to eq balance1 + balance2
        end
      end
    end
  end

  describe "#online_savings_accounts_balance" do
    let(:laa) { create(:legal_aid_application, :with_applicant) }

    context "with no current accounts" do
      it "returns nil" do
        expect(laa.online_savings_accounts_balance).to be_nil
      end
    end

    context "with bank accounts" do
      let(:balance1) { BigDecimal(rand(1...1_000_000.0), 2) }
      let(:balance2) { BigDecimal(rand(1...1_000_000.0), 2) }
      let(:bank_provider) { create(:bank_provider, applicant: laa.applicant) }

      before do
        create(:bank_account, bank_provider:, account_type: "SAVINGS", balance: balance1)
        create(:bank_account, bank_provider:, account_type: "SAVINGS", balance: balance2)
      end

      context "with only savings" do
        it "returns nil" do
          expect(laa.online_savings_accounts_balance).to eq balance1 + balance2
        end
      end
    end
  end

  describe "hmrc_employment_income?" do
    context "when there are no Employment records" do
      let(:laa) { create(:legal_aid_application) }

      before { laa.employments.destroy_all }

      it "returns false" do
        expect(laa.hmrc_employment_income?).to be false
      end
    end

    context "when there are Employment records" do
      let(:laa) { create(:legal_aid_application, :with_applicant) }

      it "returns true" do
        create(:employment, legal_aid_application: laa, owner_id: laa.applicant.id, owner_type: laa.applicant.class)
        expect(laa.reload.hmrc_employment_income?).to be true
      end
    end
  end

  describe "uploaded_evidence_by_category" do
    let(:laa) { create(:legal_aid_application) }
    let!(:collection) { create(:uploaded_evidence_collection, :with_multiple_evidence_types_attached, legal_aid_application: laa) }

    before do
      DocumentCategory.populate
    end

    context "when no evidence has been uploaded" do
      before { laa.uploaded_evidence_collection = nil }

      it "returns nil" do
        expect(laa.uploaded_evidence_by_category).to be_nil
      end
    end

    context "when evidence has been uploaded" do
      it "returns a hash of evidence attachments grouped by category" do
        # Added sort to ensure the order is consistent. Without it we got flickering tests with attachments out of order
        expect(laa.uploaded_evidence_by_category["gateway_evidence"].sort).to eq [
          find_attachment(collection.original_attachments, "Fake Gateway Evidence 1"),
          find_attachment(collection.original_attachments, "Fake Gateway Evidence 2"),
        ].sort
        expect(laa.uploaded_evidence_by_category["benefit_evidence"].sort).to eq [
          find_attachment(collection.original_attachments, "Fake Benefit Evidence 1"),
          find_attachment(collection.original_attachments, "Fake Benefit Evidence 2"),
        ].sort
      end
    end
  end

  describe "manually_entered_employment_information?" do
    let(:laa) { create(:legal_aid_application, :with_applicant) }

    context "when no employment information has been entered by the provider" do
      it "returns false" do
        expect(laa.manually_entered_employment_information?).to be false
      end
    end

    context "when extra employment information has been entered by the provider" do
      let(:laa) { create(:legal_aid_application, :with_employed_applicant_and_extra_info) }

      it "returns true" do
        expect(laa.manually_entered_employment_information?).to be true
      end
    end

    context "when full employment information has been entered by the provider" do
      before { laa.update!(full_employment_details: "test details") }

      it "returns true" do
        expect(laa.manually_entered_employment_information?).to be true
      end
    end

    context "when extra employment information has been entered for the partner" do
      let(:laa) { create(:legal_aid_application, :with_applicant) }

      before { create(:partner, :with_extra_employment_information, legal_aid_application: laa) }

      it "returns true" do
        expect(laa.manually_entered_employment_information?).to be true
      end
    end

    context "when full employment information has been entered for the partner" do
      # before { laa.update!(full_employment_details: "test details") }
      before { create(:partner, :with_full_employment_information, legal_aid_application: laa) }

      it "returns true" do
        expect(laa.manually_entered_employment_information?).to be true
      end
    end
  end

  describe "#hmrc_response_use_case_one" do
    let(:laa) { create(:legal_aid_application, :with_applicant) }
    let(:applicant) { laa.applicant }
    let!(:use_case_one) { create(:hmrc_response, :use_case_one, legal_aid_application: laa, owner_id: applicant.id, owner_type: applicant.class) }

    it "returns the use case one record" do
      create(:hmrc_response, :use_case_two, legal_aid_application: laa, owner_id: applicant.id, owner_type: applicant.class)
      expect(laa.hmrc_response_use_case_one).to eq use_case_one
    end
  end

  describe "#eligible_employment_payments" do
    let(:laa) { create(:legal_aid_application, :with_applicant, :with_transaction_period) }
    let(:applicant) { laa.applicant }

    context "with one employment with employment payments" do
      before do
        emp = create(:employment, legal_aid_application: laa, owner_id: applicant.id, owner_type: applicant.class)
        create(:employment_payment, employment: emp, date: 1.month.ago)
        create(:employment_payment, employment: emp, date: 2.months.ago)
      end

      it "returns two employment records" do
        payments = laa.eligible_employment_payments
        expect(payments.size).to eq 2
        expect(payments.map(&:class).uniq).to eq [EmploymentPayment]
      end
    end

    context "with one employment with no employment payments" do
      before { create(:employment, legal_aid_application: laa, owner_id: applicant.id, owner_type: applicant.class) }

      it "returns an empty collections" do
        expect(laa.eligible_employment_payments).to be_empty
      end
    end

    context "with no employments" do
      it "returns an empty collection" do
        expect(laa.eligible_employment_payments).to be_empty
      end
    end

    context "with multiple employments" do
      before do
        emp1 = create(:employment, legal_aid_application: laa, owner_id: applicant.id, owner_type: applicant.class)
        create(:employment_payment, employment: emp1, date: 1.month.ago)
        create(:employment_payment, employment: emp1, date: 2.months.ago)
        emp2 = create(:employment, legal_aid_application: laa, owner_id: applicant.id, owner_type: applicant.class)
        create(:employment_payment, employment: emp2, date: 1.month.ago)
      end

      it "returns one collection of three records" do
        expect(laa.eligible_employment_payments.size).to eq 3
      end
    end

    context "with all payments before start of transaction period" do
      before do
        emp1 = create(:employment, legal_aid_application: laa, owner_id: applicant.id, owner_type: applicant.class)
        create(:employment_payment, employment: emp1, date: laa.transaction_period_start_on - 3.days)
        create(:employment_payment, employment: emp1, date: laa.transaction_period_start_on - 10.days)
        emp2 = create(:employment, legal_aid_application: laa, owner_id: applicant.id, owner_type: applicant.class)
        create(:employment_payment, employment: emp2, date: laa.transaction_period_start_on - 1.month)
      end

      it "returns an empty collection" do
        expect(laa.eligible_employment_payments).to be_empty
      end
    end

    context "with one payment in transaction period, others before" do
      before do
        emp1 = create(:employment, legal_aid_application: laa, owner_id: applicant.id, owner_type: applicant.class)
        create(:employment_payment, employment: emp1, date: laa.transaction_period_start_on - 3.days)
        create(:employment_payment, employment: emp1, date: laa.transaction_period_start_on + 2.days)
        create(:employment_payment, employment: emp1, date: laa.transaction_period_start_on - 10.days)
      end

      it "returns a collection of just the one record in the transaction period" do
        expect(laa.eligible_employment_payments.size).to eq 1
      end
    end
  end

  describe "#uploading_bank_statements?" do
    let(:laa) { create(:legal_aid_application, provider_received_citizen_consent: consent) }

    context "when client permission to use true layer received" do
      let(:consent) { true }

      it "returns false" do
        expect(laa.uploading_bank_statements?).to be false
      end
    end

    context "when client permission to use true layer not received" do
      let(:consent) { false }

      it "returns true" do
        expect(laa.uploading_bank_statements?).to be true
      end
    end

    context "when client permission to use true layer not specified" do
      let(:consent) { nil }

      it "returns false" do
        expect(laa.uploading_bank_statements?).to be false
      end
    end
  end

  describe "#has_transaction_type?" do
    subject(:has_transaction_type?) { laa.has_transaction_type?(transaction_type, owner_query) }

    let(:laa) { create(:legal_aid_application, :with_applicant_and_partner_with_no_contrary_interest) }
    let(:benefits) { create(:transaction_type, :benefits) }
    let(:rent_or_mortgage) { create(:transaction_type, :rent_or_mortgage) }

    context "when application has that transaction type for the Applicant" do
      before do
        create(
          :legal_aid_application_transaction_type,
          legal_aid_application: laa,
          transaction_type: benefits,
          owner_type: "Applicant",
          owner_id: laa.applicant.id,
        )
      end

      it "returns true when querying that type for applicant" do
        expect(laa).to have_transaction_type(benefits, "Applicant")
      end

      it "returns false when querying that type for partner" do
        expect(laa).not_to have_transaction_type(benefits, "Partner")
      end

      it "returns false when querying a type that the applicant does not have" do
        expect(laa).not_to have_transaction_type(rent_or_mortgage, "Applicant")
      end
    end

    context "when application has that transaction type for the partner" do
      before do
        create(
          :legal_aid_application_transaction_type,
          legal_aid_application: laa,
          transaction_type: benefits,
          owner_type: "Partner",
          owner_id: laa.partner.id,
        )
      end

      it "returns false when querying that type for applicant" do
        expect(laa).not_to have_transaction_type(benefits, "Applicant")
      end

      it "returns true when querying that type for partner" do
        expect(laa).to have_transaction_type(benefits, "Partner")
      end

      it "returns false when querying a type that the partner does not have" do
        expect(laa).not_to have_transaction_type(rent_or_mortgage, "Partner")
      end
    end

    context "when application does not have any transaction types" do
      before do
        legal_aid_application.legal_aid_application_transaction_types.destroy_all
      end

      it "returns false when querying a type for applicant" do
        expect(laa).not_to have_transaction_type(benefits, "Applicant")
      end

      it "returns false when querying a type for partner" do
        expect(laa).not_to have_transaction_type(benefits, "Partner")
      end
    end
  end

  describe "#housing_payments?" do
    context "when the application has a rent_or_mortgage transaction type" do
      it "returns true" do
        legal_aid_application = create(:legal_aid_application)
        transaction_type = create(:transaction_type, :rent_or_mortgage)
        _rent_or_mortgage = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type:,
        )

        expect(legal_aid_application.housing_payments?).to be true
      end
    end

    context "when the application does not have a rent_or_mortgage transaction type" do
      it "returns false" do
        legal_aid_application = build_stubbed(:legal_aid_application)

        expect(legal_aid_application.housing_payments?).to be false
      end
    end
  end

  describe "#associated_applications" do
    subject(:associated_applications) { application_one.associated_applications }

    let(:application_one) { create(:legal_aid_application) }
    let(:application_two) { create(:legal_aid_application) }
    let(:application_three) { create(:legal_aid_application) }

    context "when application has no linked applications" do
      it { is_expected.to eq [] }
    end

    context "when application is the associated application" do
      before do
        create(:linked_application, :family, lead_application: application_two, associated_application: application_one)
      end

      it { is_expected.to eq [] }
    end

    context "when application is a lead applicaton" do
      before do
        create(:linked_application, :family, lead_application: application_one, associated_application: application_two)
        create(:linked_application, :family, lead_application: application_one, associated_application: application_three)
      end

      it "returns an array of associated applications" do
        expect(associated_applications).to contain_exactly(application_two, application_three)
      end
    end

    context "when associated application is the same as lead application" do
      it "does not allow an application to be linked to itself" do
        expect { create(:linked_application, :family, lead_application: application_one, associated_application: application_one) }
          .to raise_error(/Application cannot be linked to itself/)
      end
    end

    context "when destroying an associated application" do
      before do
        create(:linked_application, :family, lead_application: application_one, associated_application: application_two)
      end

      it "destroys the link but not the associated application" do
        expect { application_two.destroy! }
          .to change { application_one.reload.associated_applications }
              .from([application_two])
              .to([])
      end
    end
  end

  describe "#lead_application" do
    subject(:lead_application) { application_one.lead_application }

    let(:application_one) { create(:legal_aid_application) }
    let(:application_two) { create(:legal_aid_application) }

    context "when application has no linked applications" do
      it { is_expected.to be_nil }
    end

    context "when application is the lead application" do
      before do
        create(:linked_application, :family, lead_application: application_one, associated_application: application_two)
      end

      it { is_expected.to be_nil }
    end

    context "when application is an associated applicaton" do
      before do
        create(:linked_application, :family, lead_application: application_two, associated_application: application_one)
      end

      it "returns the single lead application" do
        expect(lead_application).to eq application_two
      end
    end

    context "when destroying a lead application" do
      before do
        create(:linked_application, :family, lead_application: application_one, associated_application: application_two)
      end

      it "destroys the link but not the associated application" do
        expect { application_one.destroy! }
          .to change { application_two.reload.lead_application }
              .from(application_one)
              .to(nil)
      end
    end
  end

  describe "#link_description" do
    subject(:link_description) { legal_aid_application.link_description }

    context "when fully populated" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_proceedings, proceeding_count: 2) }

      it "returns the expected data" do
        expected = "#{legal_aid_application.applicant.full_name}, <span class='no-wrap'>#{legal_aid_application.application_ref}</span>, #{legal_aid_application.proceedings.map(&:meaning).join(', ')}"
        expect(link_description).to eql(expected)
      end
    end

    context "when the proceedings are not created" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

      it "returns the expected data" do
        expect(link_description).to eql("#{legal_aid_application.applicant.full_name}, <span class='no-wrap'>#{legal_aid_application.application_ref}</span>")
      end
    end

    context "when the applicant is not created" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings) }

      it "returns the expected data" do
        expect(link_description).to eql("<span class='no-wrap'>#{legal_aid_application.application_ref}</span>, Inherent jurisdiction high court injunction")
      end
    end
  end

  describe "#substantive_cost_overridable?" do
    subject { legal_aid_application.substantive_cost_overridable? }

    let(:legal_aid_application) { create(:legal_aid_application) }

    context "when the substantive_cost_limitation for the proceeding(s) is 25000 or more" do
      before { create(:proceeding, :da001, legal_aid_application:, substantive_cost_limitation: 25_000) }

      it { is_expected.to be false }
    end

    context "when the substantive_cost_limitation for the proceeding(s) is less than 25000" do
      before { create(:proceeding, :da001, legal_aid_application:, substantive_cost_limitation: 24_999) }

      it { is_expected.to be true }
    end

    context "when there are special childrens act proceedings" do
      before { create(:proceeding, :pb003, legal_aid_application:, substantive_cost_limitation: 24_999) }

      it { is_expected.to be false }
    end

    context "when the application is is an associated family linked application" do
      let(:lead_application) { create(:legal_aid_application) }

      before do
        create(:linked_application, lead_application:, associated_application: legal_aid_application, link_type_code: "FC_LEAD")
        create(:proceeding, :da001, legal_aid_application:, substantive_cost_limitation: 24_999)
      end

      it { is_expected.to be false }
    end
  end

  describe "#emergency_cost_overridable?" do
    subject { legal_aid_application.emergency_cost_overridable? }

    let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, :with_delegated_functions_on_proceedings, explicit_proceedings: %i[da001], df_options: { DA001: [Time.zone.today, Time.zone.today] }) }

    context "when the provider has used delegated functions" do
      it { is_expected.to be true }
    end

    context "when the provider has not used delegated functions" do
      let(:legal_aid_application) { create(:legal_aid_application) }

      it { is_expected.to be false }
    end

    context "when there are special childrens act proceedings" do
      before { legal_aid_application.proceedings << create(:proceeding, :pb003) }

      it { is_expected.to be false }
    end

    context "when the application is is an associated family linked application" do
      let(:lead_application) { create(:legal_aid_application) }

      before { create(:linked_application, lead_application:, associated_application: legal_aid_application, link_type_code: "FC_LEAD") }

      it { is_expected.to be false }
    end
  end

  describe "#related_proceedings" do
    subject { legal_aid_application.related_proceedings }

    let(:core_proceeding) { create(:proceeding, :pb003) }

    before { legal_aid_application.proceedings << core_proceeding }

    context "when the application does not have related sca proceedings" do
      it { is_expected.to eq [] }
    end

    context "when there are special childrens act proceedings" do
      let(:related_proceeding) { create(:proceeding, :pb007) }

      before { legal_aid_application.proceedings << related_proceeding }

      it { is_expected.to eq [related_proceeding] }
    end
  end

  describe "#biological_parent_relationship?" do
    subject { legal_aid_application.biological_parent_relationship? }

    context "when the applicant has a biological_parent relationship" do
      before { create(:applicant, legal_aid_application:, relationship_to_children: "biological") }

      it { is_expected.to be true }
    end

    context "when the applicant does not have a biological parent relationship" do
      before { create(:applicant, legal_aid_application:, relationship_to_children: nil) }

      it { is_expected.to be false }
    end
  end

  describe "#parental_responsibility_court_order_relationship?" do
    subject { legal_aid_application.parental_responsibility_court_order_relationship? }

    context "with a proceeding with a parental_responsibility_court_order relationship" do
      before { create(:applicant, legal_aid_application:, relationship_to_children: "court_order") }

      it { is_expected.to be true }
    end

    context "without a proceeding with a parental_responsibility_court_order relationship" do
      before { create(:applicant, legal_aid_application:, relationship_to_children: nil) }

      it { is_expected.to be false }
    end
  end

  describe "#parental_responsibility_agreement_relationship?" do
    subject { legal_aid_application.parental_responsibility_agreement_relationship? }

    context "with a proceeding with a parental_responsibility_agreement relationship" do
      before { create(:applicant, legal_aid_application:, relationship_to_children: "parental_responsibility_agreement") }

      it { is_expected.to be true }
    end

    context "without a proceeding with a parental_responsibility_agreement relationship" do
      before { create(:applicant, legal_aid_application:, relationship_to_children: nil) }

      it { is_expected.to be false }
    end
  end

  describe "#child_subject_relationship?" do
    subject { legal_aid_application.child_subject_relationship? }

    context "with a proceeding with a child_subject relationship" do
      before { create(:applicant, legal_aid_application:, relationship_to_children: "child_subject") }

      it { is_expected.to be true }
    end

    context "without a proceeding with a child_subject relationship" do
      before { create(:applicant, legal_aid_application:, relationship_to_children: nil) }

      it { is_expected.to be false }
    end
  end

  describe "#parental_responsibility_evidence?" do
    subject { legal_aid_application.parental_responsibility_evidence? }

    context "with aan application that has parental responsibility evidence" do
      let(:legal_aid_application) { create(:legal_aid_application, attachments: [parental_responsibility_evidence]) }
      let(:parental_responsibility_evidence) { create(:attachment, :parental_responsibility, attachment_name: "parental_responsibility") }

      it { is_expected.to be true }
    end

    context "without a proceeding with a child_subject relationship" do
      it { is_expected.to be false }
    end
  end

  describe "ecct_routing?" do
    subject { legal_aid_application.ecct_routing? }

    context "when there is no appeal" do
      it { is_expected.to be false }
    end

    context "when there is an appeal" do
      let(:legal_aid_application) do
        create(:legal_aid_application,
               :with_second_appeal,
               second_appeal:,
               original_judge_level: nil,
               court_type:)
      end
      let(:second_appeal) { false }
      let(:court_type) { "court_of_appeal" }

      context "and second_appeal is false" do
        it { is_expected.to be false }
      end

      context "and second_appeal is true" do
        let(:second_appeal) { true }

        it { is_expected.to be true }
      end
    end
  end

private

  def find_attachment(evidence_collection, filename)
    evidence_collection.find { |attachment| attachment.original_filename == filename }
  end
end
