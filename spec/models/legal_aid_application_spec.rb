require "rails_helper"

RSpec.describe LegalAidApplication, type: :model do
  let(:legal_aid_application) { create :legal_aid_application }

  describe "#capture_policy_disregards?" do
    subject { legal_aid_application.capture_policy_disregards? }

    context "when calculation date is nil" do
      before { expect(legal_aid_application).to receive(:calculation_date).and_return(nil) }

      context "with today's date before start of policy disregards" do
        it "returns false" do
          travel_to Time.zone.local(2021, 1, 7, 13, 45)
          expect(subject).to be false
          travel_back
        end
      end

      context "with today's date after start of policy disregards" do
        it "returns true" do
          travel_to Time.zone.local(2021, 1, 8, 13, 45)
          expect(subject).to be true
          travel_back
        end
      end
    end

    context "with calculation date set" do
      before { expect(legal_aid_application).to receive(:calculation_date).and_return(calculation_date) }

      context "with today's date before start of policy disregards" do
        let(:calculation_date) { Date.new(2021, 1, 7) }

        it "returns false" do
          travel_to Time.zone.local(2021, 1, 7, 13, 45)
          expect(subject).to be false
          travel_back
        end
      end

      context "with today's date after start of policy disregards" do
        let(:calculation_date) { Date.new(2021, 1, 8) }

        it "returns true" do
          travel_to Time.zone.local(2021, 1, 8, 13, 45)
          expect(subject).to be true
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
        before { create :policy_disregards, legal_aid_application: }

        it "returns false" do
          expect(legal_aid_application.policy_disregards?).to be false
        end
      end

      context "when none selected is false" do
        before { create :policy_disregards, legal_aid_application:, national_emergencies_trust: true }

        it "returns true" do
          expect(legal_aid_application.policy_disregards?).to be true
        end
      end
    end
  end

  describe "#add_benefit_check_result" do
    let(:benefit_check_response) do
      {
        benefit_checker_status: Faker::Lorem.word,
        confirmation_ref: SecureRandom.hex,
      }
    end

    before do
      legal_aid_application.save!
      allow(BenefitCheckService).to receive(:call).with(legal_aid_application).and_return(benefit_check_response)
    end

    it "creates a check_benefit_result with the right values" do
      legal_aid_application.add_benefit_check_result
      expect(legal_aid_application.benefit_check_result.result).to eq(benefit_check_response[:benefit_checker_status])
      expect(legal_aid_application.benefit_check_result.dwp_ref).to eq(benefit_check_response[:confirmation_ref])
    end

    context "when benefit check service is down" do
      let(:benefit_check_response) { false }

      it "returns false" do
        expect(legal_aid_application.add_benefit_check_result).to be false
      end

      it "leaves benefit_check_result empty" do
        legal_aid_application.add_benefit_check_result
        expect(legal_aid_application.benefit_check_result).to be_nil
      end
    end
  end

  describe "#lead_application_proceeding_type" do
    context "when application proceeding types exist" do
      let!(:legal_aid_application) do
        create :legal_aid_application,
               :with_applicant,
               :with_proceedings,
               set_lead_proceeding: :da001,
               explicit_proceedings: %i[se014 da001]
      end
      let(:da001) { legal_aid_application.proceedings.find_by(ccms_code: "DA001") }
      let(:se014) { legal_aid_application.proceedings.find_by(ccms_code: "SE014") }
      let!(:chances_of_success) do
        create :chances_of_success, :with_optional_text, proceeding: da004
      end
      let!(:chances_of_success) do
        create :chances_of_success, :with_optional_text, proceeding: se014
      end

      it "returns the lead proceeding" do
        expect(legal_aid_application.lead_proceeding).to eq da001
      end
    end
  end

  describe "#pre_dwp_check?" do
    let(:state) { :initiated }
    let!(:legal_aid_application) { create :legal_aid_application, :with_applicant, state }

    context "when in pre-dwp-check state" do
      it "is true" do
        expect(legal_aid_application.pre_dwp_check?).to be true
      end
    end

    context "when in non-passported state" do
      let!(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :with_applicant, state }
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
    it "returns true if transaction type credits exist" do
      benefits = build_stubbed(:transaction_type, :benefits)
      transaction_types = class_double(TransactionType, credits: [benefits])
      legal_aid_application = build_stubbed(:legal_aid_application)
      allow(legal_aid_application).to receive(:transaction_types).and_return(transaction_types)

      income_types_exist = legal_aid_application.income_types?

      expect(income_types_exist).to be true
    end

    it "returns false if no transaction type credits exist" do
      transaction_types = class_double(TransactionType, credits: [])
      legal_aid_application = build_stubbed(:legal_aid_application)
      allow(legal_aid_application).to receive(:transaction_types).and_return(transaction_types)

      income_types_exist = legal_aid_application.income_types?

      expect(income_types_exist).to be false
    end
  end

  describe "#statement_of_case_uploaded?" do
    let(:legal_aid_application) { create :legal_aid_application }

    context "with statement of case files attached" do
      let!(:statement_of_case) { create :statement_of_case, :with_original_file_attached, legal_aid_application: }

      it "is true" do
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
    let!(:legal_aid_application) { create :legal_aid_application, :with_applicant, :at_entering_applicant_details }
    let(:applicant) { legal_aid_application.applicant }

    it "is true if no benefit check results" do
      expect(legal_aid_application).to be_benefit_check_result_needs_updating
    end

    context "with up to date benefit check results" do
      let!(:benefit_check_result) { create :benefit_check_result, legal_aid_application: }

      it "returns false" do
        expect(legal_aid_application).not_to be_benefit_check_result_needs_updating
      end

      context "but later, applicant first name updated" do
        before { applicant.update(first_name: Faker::Name.first_name) }

        let!(:benefit_check_result) { travel(-10.minutes) { create :benefit_check_result, legal_aid_application: } }

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

  describe "#generate_secure_id" do
    subject { legal_aid_application.generate_secure_id }

    let(:legal_aid_application) { create :legal_aid_application }
    let(:secure_data) { SecureData.last }

    it "generates a new secure data object" do
      expect { subject }.to change(SecureData, :count).by(1)
    end

    it "returns the generated id" do
      expect(subject).to eq(secure_data.id)
    end

    it "generates data that can be used to find legal_aid_application" do
      data = SecureData.for(subject)[:legal_aid_application]
      expect(data).to be_present
      expect(described_class.find_by(data)).to eq(legal_aid_application)
    end

    it "generates data that contains a date which is in 8 days" do
      data = SecureData.for(subject)
      expire_date = (Time.current + LegalAidApplication::SECURE_ID_DAYS_TO_EXPIRE.days).end_of_day
      expect(data[:expired_at]).to be_between(expire_date - 1.minute, expire_date + 1.minute)
    end
  end

  describe "state machine" do
    subject(:legal_aid_application) { create(:legal_aid_application) }

    it 'is created with a default state of "initiated"' do
      expect(legal_aid_application.state).to eq("initiated")
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

    it "calls on rails notification service" do
      expect(ActiveSupport::Notifications).to receive(:instrument).with(any_args)
      legal_aid_application.merits_complete!
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
    context "when transaction types have associated bank transactions" do
      let(:applicant) { create :applicant }
      let(:bank_provider) { create :bank_provider, applicant: }
      let(:bank_account) { create :bank_account, bank_provider: }
      let!(:transaction_type) { create :transaction_type, :credit, name: "salary" }
      let!(:bank_transaction) { create :bank_transaction, :credit, transaction_type:, bank_account: }
      let(:legal_aid_application) { create :legal_aid_application, applicant:, transaction_types: [transaction_type] }

      context "with income transactions" do
        let!(:transaction_type) { create :transaction_type, :credit, name: "salary" }

        it "returns false" do
          expect(legal_aid_application.uncategorised_transactions?(:credit)).to be false
        end
      end

      context "with outgoing transactions" do
        let(:transaction_type) { create :transaction_type, :debit }
        let!(:bank_transaction) { create :bank_transaction, :debit, transaction_type:, bank_account: }

        it "returns false" do
          expect(legal_aid_application.uncategorised_transactions?(:debit)).to be false
        end
      end
    end

    context "when transaction types do not have associated bank transactions" do
      let(:applicant) { create :applicant }
      let(:bank_provider) { create :bank_provider, applicant: }
      let(:bank_account) { create :bank_account, bank_provider: }
      let!(:transaction_type) { create :transaction_type, :credit, name: "salary" }
      let!(:bank_transaction) { create :bank_transaction, :credit, transaction_type: nil, bank_account: }
      let(:legal_aid_application) { create :legal_aid_application, applicant:, transaction_types: [transaction_type] }

      context "with income transactions" do
        it "returns true" do
          expect(legal_aid_application.uncategorised_transactions?(:credit)).to be true
        end
      end

      context "with outgoing transactions" do
        let!(:bank_transaction) { create :bank_transaction, :debit, transaction_type: nil, bank_account: }
        let!(:transaction_type) { create :transaction_type, :debit }

        it "returns true" do
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
      let(:legal_aid_application) { create :legal_aid_application, :without_own_home }

      it "returns false" do
        expect(legal_aid_application.own_home?).to be(false)
      end
    end

    context 'when legal_aid_application.own_home is not "no"' do
      let(:legal_aid_application) { create :legal_aid_application, :with_own_home_mortgaged }

      it "returns true" do
        expect(legal_aid_application.own_home?).to be(true)
      end
    end
  end

  describe "#own_capital?" do
    context "with no home, savings or assets" do
      let(:legal_aid_application) { create :legal_aid_application, own_home: nil }

      it "returns nil" do
        expect(legal_aid_application.own_capital?).to be false
      end
    end

    context "with own home" do
      let(:legal_aid_application) { create :legal_aid_application, :with_own_home_mortgaged }

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

  describe "set_transaction_period" do
    subject { legal_aid_application.set_transaction_period }

    it "sets start" do
      subject
      expect(legal_aid_application.transaction_period_start_on).to eq(Date.current - 3.months)
    end

    it "sets finish" do
      subject
      expect(legal_aid_application.transaction_period_finish_on).to eq(Date.current)
    end

    context "when delegated functions are used" do
      let!(:legal_aid_application) do
        create :legal_aid_application,
               :with_proceedings,
               :with_delegated_functions_on_proceedings,
               explicit_proceedings: [:da004],
               set_lead_proceeding: :da004,
               df_options: { DA004: [used_delegated_functions_on, used_delegated_functions_reported_on] }
      end
      let(:proceedings) { legal_aid_application.proceedings }
      let!(:used_delegated_functions_reported_on) { Time.zone.today }
      let!(:used_delegated_functions_on) { Faker::Date.backward }

      it "sets start and finish relative to used_delegated_functions_on" do
        subject
        expect(legal_aid_application.transaction_period_start_on).to eq(proceedings.first.used_delegated_functions_on - 3.months)
        expect(legal_aid_application.transaction_period_finish_on).to eq(proceedings.first.used_delegated_functions_on)
      end
    end
  end

  describe "#submitted_to_ccms?" do
    context "when application not submitted to ccms" do
      let(:legal_aid_application) { create :legal_aid_application }

      it "returns false" do
        expect(legal_aid_application.submitted_to_ccms?).to be(false)
      end
    end

    context "when application submitted to ccms" do
      let(:legal_aid_application) { create :legal_aid_application, :submitted_to_ccms }

      it "returns true" do
        expect(legal_aid_application.submitted_to_ccms?).to be(true)
      end
    end
  end

  describe "#proceedings_used_delegated_functions?" do
    context "when application uses df" do
      let(:legal_aid_application) { create :legal_aid_application, :with_proceedings, explicit_proceedings: [:da004], set_lead_proceeding: :da004 }

      it "returns true" do
        expect(legal_aid_application.proceedings_used_delegated_functions?).to be(true)
      end
    end

    context "when application does not use df" do
      let(:legal_aid_application) { create :legal_aid_application, :with_proceedings }

      it "returns false" do
        expect(legal_aid_application.proceedings_used_delegated_functions?).to be(false)
      end
    end
  end

  describe "#read_only?" do
    context "when provider application not submitted" do
      let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine }

      it "returns false" do
        expect(legal_aid_application.read_only?).to be(false)
      end
    end

    context "when provider submitted" do
      let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :applicant_entering_means }

      it "returns true" do
        expect(legal_aid_application.read_only?).to be(true)
      end
    end

    context "when checking citizen answers?" do
      let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :checking_citizen_answers }

      it "returns true" do
        expect(legal_aid_application.read_only?).to be(true)
      end
    end
  end

  describe "attributes are synced on applicant_details_checked" do
    let(:legal_aid_application) { create :legal_aid_application, :with_everything, :without_own_home, :checking_applicant_details }

    it "passes application to keep in sync service" do
      expect(CleanupCapitalAttributes).to receive(:call).with(legal_aid_application)
      legal_aid_application.applicant_details_checked!
    end

    context "and attributes changed" do
      before do
        legal_aid_application.applicant_details_checked!
        legal_aid_application.reload
      end

      it "resets property values" do
        expect(legal_aid_application.property_value).to be_blank
      end

      it "resets outstanding mortgage" do
        expect(legal_aid_application.outstanding_mortgage_amount).to be_blank
      end

      it "resets shared ownership" do
        expect(legal_aid_application.shared_ownership).to be_blank
      end

      it "resets percentage home" do
        expect(legal_aid_application.percentage_home).to be_blank
      end
    end
  end

  # Main purpose: to ensure relationships to other objects set so that destroying application destroys all objects
  # that then become redundant.
  describe ".destroy_all" do
    subject { described_class.destroy_all }

    let!(:legal_aid_application) do
      create :legal_aid_application,
             :with_everything,
             :with_multiple_proceedings_inc_section8,
             :with_negative_benefit_check_result,
             :with_bank_transactions,
             :with_chances_of_success
    end

    before do
      create :legal_aid_application_transaction_type, legal_aid_application:
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
      expect { subject }.to change(described_class, :count).to(0)
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
      subject
      expect(TransactionType.count).not_to be_zero
    end
  end

  describe "#create_app_ref" do
    it "generates an application_ref when the application is created" do
      legal_aid_application = described_class.create!(provider: (create :provider))
      expect(legal_aid_application.application_ref).to match(/L(-[ABCDEFHJKLMNPRTUVWXY0-9]{3}){2}/)
    end
  end

  describe "state label" do
    let(:states) { legal_aid_application.state_machine_proxy.aasm.states.map(&:name) }

    context "with passported states" do
      it "has a translation for all states" do
        states.each do |state|
          expect(I18n.exists?("model_enum_translations.legal_aid_application.state.#{state}")).to be(true)
        end
      end
    end

    context "with non-passported states" do
      before { legal_aid_application.change_state_machine_type("NonPassportedStateMachine") }

      it "has a translation for all states" do
        states.each do |state|
          expect(I18n.exists?("model_enum_translations.legal_aid_application.state.#{state}")).to be(true)
        end
      end
    end
  end

  describe "#used_delegated_functions?" do
    let!(:legal_aid_application) do
      create :legal_aid_application,
             :with_proceedings,
             :with_delegated_functions_on_proceedings,
             explicit_proceedings: [:da004],
             set_lead_proceeding: :da004,
             df_options: { DA004: [Time.zone.now, Time.zone.now] }
    end

    context "when delegated functions used" do
      it "returns true" do
        expect(legal_aid_application.used_delegated_functions?).to be true
      end
    end

    context "when delegated functions not used" do
      let!(:legal_aid_application) { create :legal_aid_application, :with_proceedings }

      it "returns false" do
        expect(legal_aid_application.used_delegated_functions?).to be false
      end
    end
  end

  describe "#earliest_delegated_functions_date" do
    let(:laa) { create :legal_aid_application }
    let!(:proceeding1) { create :proceeding, :da001, legal_aid_application: laa, used_delegated_functions: true, used_delegated_functions_on: date1 }
    let!(:proceeding2) { create :proceeding, :se013, legal_aid_application: laa, used_delegated_functions: true, used_delegated_functions_on: date2 }
    let!(:proceeding3) { create :proceeding, :se014, legal_aid_application: laa }

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

  describe "default_cost_limitations" do
    context "when substantive" do
      let(:application) { create :legal_aid_application, :with_proceedings, set_lead_proceeding: :da001 }

      it "returns the substantive cost limitation for the first proceeding type" do
        expect(application.default_cost_limitation).to eq 25_000.0
      end
    end

    context "with delegated functions" do
      let(:legal_aid_application) { create :legal_aid_application, :with_proceedings, proceeding_count: 4, set_lead_proceeding: :da004 }
      let(:da004) { legal_aid_application.proceedings.find_by(ccms_code: "DA004") }
      let!(:chances_of_success) do
        create :chances_of_success, :with_optional_text, proceeding: da004
      end

      it "returns the substantive cost limitation for the proceeding" do
        expect(legal_aid_application.default_cost_limitation).to eq 25_000.0
      end
    end

    context "when the lead application has a smaller substantive cost limit" do
      let(:legal_aid_application) { create :legal_aid_application }
      let!(:proceeding1) { create :proceeding, :da006, legal_aid_application:, substantive_cost_limitation: 5_000, lead_proceeding: true }
      let!(:proceeding2) { create :proceeding, :se013, legal_aid_application: }

      it "takes the largest cost value" do
        expect(legal_aid_application.default_cost_limitation).to eq 25_000.0
      end
    end
  end

  describe "substantive_cost_limitation" do
    subject(:substantive_cost_limitation) { legal_aid_application.substantive_cost_limitation }

    let(:legal_aid_application) { create :legal_aid_application }
    let!(:proceeding1) { create :proceeding, :da006, legal_aid_application:, substantive_cost_limitation: 5_000, lead_proceeding: true }
    let!(:proceeding2) { create :proceeding, :se013, legal_aid_application:, substantive_cost_limitation: 10_000 }

    context "when the provider accepts the default" do
      it { is_expected.to eq 10_000 }
    end

    context "when the provider has overridden a smaller default" do
      let(:legal_aid_application) do
        create :legal_aid_application,
               substantive_cost_override: true,
               substantive_cost_requested: 12_000,
               substantive_cost_reasons: "something... something... reasons"
      end

      it { is_expected.to eq 12_000 }
    end
  end

  describe "#bank_transactions" do
    subject { legal_aid_application.bank_transactions }

    let(:transaction_period_start_on) { "2019-08-10".to_date }
    let(:transaction_period_finish_on) { "2019-08-20".to_date }
    let(:date_before_start) { "2019-08-09 23:40 +0100".to_time }
    let(:date_after_start)  { "2019-08-10 00:20 +0100".to_time }
    let(:date_before_end)   { "2019-08-20 23:40 +0100".to_time }
    let(:date_after_end)    { "2019-08-21 00:20 +0100".to_time }
    let(:legal_aid_application) do
      create :legal_aid_application,
             :with_applicant,
             transaction_period_start_on:,
             transaction_period_finish_on:
    end
    let(:bank_provider) { create :bank_provider, applicant: legal_aid_application.applicant }
    let(:bank_account) { create :bank_account, bank_provider: }
    let!(:transaction_before_start) { create :bank_transaction, bank_account:, happened_at: date_before_start }
    let!(:transaction_after_start) { create :bank_transaction, bank_account:, happened_at: date_after_start }
    let!(:transaction_before_end) { create :bank_transaction, bank_account:, happened_at: date_before_end }
    let!(:transaction_after_end) { create :bank_transaction, bank_account:, happened_at: date_after_end }
    let(:transaction_ids) { subject.pluck(:id) }

    it "returns the all transactions" do
      expect(transaction_ids).to include(transaction_after_start.id)
      expect(transaction_ids).to include(transaction_before_end.id)
      expect(transaction_ids).to include(transaction_before_start.id)
      expect(transaction_ids).to include(transaction_after_end.id)
    end
  end

  describe "applicant_receives_benefit?" do
    context "when benefit_check_result exists?" do
      context "when passported" do
        before { create :benefit_check_result, :positive, legal_aid_application: }

        context "with no DWP Override" do
          it "returns true" do
            expect(legal_aid_application.applicant_receives_benefit?).to be true
          end

          it "returns true for the aliased method #passported?" do
            expect(legal_aid_application.passported?).to be true
          end
        end

        context "with DWP override" do
          before { create :dwp_override, legal_aid_application: }

          it "returns true" do
            expect(legal_aid_application.applicant_receives_benefit?).to be true
          end
        end
      end

      context "when not passported" do
        before { create :benefit_check_result, legal_aid_application: }

        context "with no DWP override" do
          it "returns false" do
            expect(legal_aid_application.applicant_receives_benefit?).to be false
          end

          it "returns true for the alias non_passported" do
            expect(legal_aid_application.non_passported?).to be true
          end
        end

        context "with DWP Override" do
          context "when the provider selects yes for evidence" do
            before { create :dwp_override, :with_evidence, legal_aid_application: }

            it "returns true" do
              expect(legal_aid_application.applicant_receives_benefit?).to be true
            end

            it "returns false for the alias non_passported" do
              expect(legal_aid_application.non_passported?).to be false
            end
          end

          context "when the provider selects no for evidence" do
            before { create :dwp_override, :with_no_evidence, legal_aid_application: }

            it "returns false" do
              expect(legal_aid_application.applicant_receives_benefit?).to be false
            end

            it "returns true for the alias non_passported" do
              expect(legal_aid_application.non_passported?).to be true
            end
          end
        end
      end

      context "when undetermined" do
        before { create :benefit_check_result, :undetermined, legal_aid_application: }

        context "with no DWP Override" do
          it "returns false" do
            expect(legal_aid_application.applicant_receives_benefit?).to be false
          end
        end

        context "with DWP Override" do
          before { create :dwp_override, :with_evidence, legal_aid_application: }

          it "returns true" do
            expect(legal_aid_application.applicant_receives_benefit?).to be true
          end
        end
      end
    end

    context "when benefit_check_result does not exist" do
      it "returns false" do
        expect(legal_aid_application.applicant_receives_benefit?).to be false
      end
    end
  end

  describe "#generated_reports" do
    let(:legal_aid_application) { create :legal_aid_application, :generating_reports }
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
    let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :checking_merits_answers }
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

  describe "complete means event" do
    let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :checking_citizen_answers }

    it "runs the complete means service and the bank transaction analyser" do
      expect(ApplicantCompleteMeans).to receive(:call).with(legal_aid_application)
      expect(BankTransactionsAnalyserJob).to receive(:perform_later).with(legal_aid_application)
      legal_aid_application.complete_non_passported_means!
    end
  end

  describe ".search" do
    let!(:application1) { create :legal_aid_application, application_ref: "L-123-ABC" }
    let(:jacob) { create :applicant, first_name: "Jacob", last_name: "Rees-Mogg" }
    let!(:application2) { create :legal_aid_application, applicant: jacob }
    let(:ccms_submission) { create :submission, case_ccms_reference: "300000000009" }
    let!(:application3) { create :legal_aid_application, ccms_submission: }
    let(:non_alphanum) { /[^0-9a-zA-Z]/.random_example }

    it "matches application_ref" do
      [
        "L 123 ABC",
        "L123ABC",
        "l123abc",
        "L/123/ABC",
        "L123#{non_alphanum}ABC",
      ].each do |term|
        expect(described_class.search(term)).to include(application1), term
      end
      expect(described_class.search("something")).not_to include(application1)
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
        "jac#{non_alphanum}ob",
      ].each do |term|
        expect(described_class.search(term)).to include(application2), term
      end
      expect(described_class.search("something")).not_to include(application2)
    end

    it "matches ccms case reference number" do
      [
        "300",
        "0",
        "9",
        "09",
        "0#{non_alphanum}9",
      ].each do |term|
        expect(described_class.search(term)).to include(application3), term
      end
      expect(described_class.search("something")).not_to include(application3)
    end
  end

  describe "#cfe_result" do
    it "returns the result associated with the most recent CFE::Submission" do
      travel(-10.minutes) do
        legal_aid_application = create :legal_aid_application
        submission1 = create :cfe_submission, legal_aid_application: legal_aid_application
        create :cfe_v3_result, submission: submission1
      end
      submission2 = create :cfe_submission, legal_aid_application: legal_aid_application
      result2 = create :cfe_v3_result, submission: submission2

      expect(legal_aid_application.cfe_result).to eq result2
    end
  end

  describe "#transaction_types" do
    let(:legal_aid_application) { create :legal_aid_application }
    let!(:ff) { create :transaction_type, :friends_or_family }
    let!(:salary) { create :transaction_type, :salary }
    let!(:maintenance) { create :transaction_type, :maintenance_out }
    let!(:child_care) { create :transaction_type, :child_care }
    let!(:ff_tt) { create :legal_aid_application_transaction_type, transaction_type: ff, legal_aid_application: }
    let!(:maintenance_tt) { create :legal_aid_application_transaction_type, transaction_type: maintenance, legal_aid_application: }

    it "returns an array of transaction type records" do
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

  describe "after_save hook" do
    context "when an application is created" do
      let(:application) { create :legal_aid_application, :with_proceedings }

      it { expect(application.used_delegated_functions?).to be false }

      context "and the used_delegated_functions is changed and saved" do
        subject { application.save }

        before do
          ActiveJob::Base.queue_adapter = :test
        end

        after { ActiveJob::Base.queue_adapter = :sidekiq }

        it "fires an ActiveSupport::Notification" do
          expect { subject }.to have_enqueued_job(Dashboard::UpdaterJob).with("Applications").at_least(1).times
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
        create :legal_aid_application_transaction_type, legal_aid_application: legal_aid_application, transaction_type: pension
        create :legal_aid_application_transaction_type, legal_aid_application: legal_aid_application, transaction_type: benefits
        create :legal_aid_application_transaction_type, legal_aid_application:, transaction_type: excluded_benefits
      end

      it "returns parent and stand-alone" do
        expect(legal_aid_application.parent_transaction_types).to match_array [pension, benefits]
      end
    end

    context "with legal aid application child and stand-alone transaction types" do
      before do
        create :legal_aid_application_transaction_type, legal_aid_application: legal_aid_application, transaction_type: pension
        create :legal_aid_application_transaction_type, legal_aid_application:, transaction_type: excluded_benefits
      end

      it "returns parent and stand-alone" do
        expect(legal_aid_application.parent_transaction_types).to match_array [pension, benefits]
      end
    end

    context "with legal aid application parent and stand-alone transaction types" do
      before do
        create :legal_aid_application_transaction_type, legal_aid_application: legal_aid_application, transaction_type: pension
        create :legal_aid_application_transaction_type, legal_aid_application:, transaction_type: benefits
      end

      it "returns parent and stand-alone" do
        expect(legal_aid_application.parent_transaction_types).to match_array [pension, benefits]
      end
    end
  end

  context "when initialising a new object" do
    it "instantiates the default state machine" do
      expect(legal_aid_application.state_machine_proxy.type).to eq "PassportedStateMachine"
      expect(legal_aid_application.state).to eq "initiated"
    end
  end

  context "with advancing state" do
    it "advances state and saves" do
      legal_aid_application.enter_applicant_details!
      expect(legal_aid_application.state).to eq "entering_applicant_details"
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

  context "when switching state machines" do
    it "switches to the new state machine" do
      expect(legal_aid_application.state_machine).to be_instance_of(PassportedStateMachine)
      legal_aid_application.change_state_machine_type("NonPassportedStateMachine")
      expect(legal_aid_application.state_machine).to be_instance_of(NonPassportedStateMachine)
    end
  end

  context "with delegated state machine methods" do
    let(:application) { create :legal_aid_application, :with_passported_state_machine }

    describe "#provider_assessing_means" do
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
    let(:laa) { create :legal_aid_application, :with_proceedings, proceeding_count: 4 }
    let(:proceeding_da001) { laa.proceedings.detect { |p| p.ccms_code == "DA001" } }
    let(:proceeding_se014) { laa.proceedings.detect { |p| p.ccms_code == "SE014" } }

    it "returns an array of all the chances of success records" do
      cos_da001 = create :chances_of_success, proceeding: proceeding_da001
      cos_se014 = create :chances_of_success, proceeding: proceeding_se014

      expect(laa.chances_of_success).to match_array([cos_da001, cos_se014])
    end
  end

  describe "#attempts_to_settle" do
    let(:laa) { create :legal_aid_application, :with_proceedings, proceeding_count: 4 }
    let(:proceeding_da001) { laa.proceedings.detect { |p| p.ccms_code == "DA001" } }
    let(:proceeding_se014) { laa.proceedings.detect { |p| p.ccms_code == "SE014" } }

    it "returns an array of attempt_to_settle records attached to the application" do
      ats_da001 = create :attempts_to_settles, proceeding: proceeding_da001
      ats_se014 = create :attempts_to_settles, proceeding: proceeding_se014

      expect(laa.attempts_to_settles).to match_array([ats_da001, ats_se014])
    end
  end

  describe "#lead_proceeding" do
    let(:laa) { create :legal_aid_application, :with_proceedings, proceeding_count: 4, set_lead_proceeding: :da004 }
    let(:proceeding_da004) { laa.proceedings.detect { |p| p.ccms_code == "DA004" } }

    it "returns the domestic abuse proceeding" do
      expect(laa.lead_proceeding).to eq proceeding_da004
    end
  end

  describe "#find or set lead proceeding" do
    context "with lead proceeding already set" do
      let(:laa) { create :legal_aid_application, :with_proceedings, proceeding_count: 4, set_lead_proceeding: :da004 }
      let(:da004) { laa.proceedings.find_by(ccms_code: "DA004") }

      it "returns the lead proceeding" do
        expect(laa.find_or_set_lead_proceeding).to eq da004
      end
    end

    context "with no lead proceeding set" do
      let(:laa) { create :legal_aid_application, :with_proceedings, proceeding_count: 4, set_lead_proceeding: false }

      it "returns one of the domestic abuse proceedings" do
        expect(laa.lead_proceeding).to be_nil
        lead_proc = laa.find_or_set_lead_proceeding
        expect(lead_proc.ccms_code).to match(/^DA/)
      end

      it "has set the lead proceeding to true" do
        lead_proc = laa.find_or_set_lead_proceeding
        expect(lead_proc.lead_proceeding).to be true
      end
    end
  end

  describe "#proceedings_by_name" do
    subject { laa.proceedings_by_name }

    let(:laa) { create :legal_aid_application }

    before do
      laa.proceedings << create(:proceeding, :se013)
      laa.proceedings << create(:proceeding, :se014)
      laa.proceedings << create(:proceeding, :da004)
    end

    it "returns an array of three items" do
      expect(subject.size).to eq 3
    end

    it "returns se013 as the first item" do
      item = subject.first
      expect(item).to be_an_instance_of(LegalAidApplication::ProceedingStruct)
      expect(item.name).to eq "child_arrangements_order_contact"
      expect(item.meaning).to eq "Child arrangements order (contact)"
      expect(item.proceeding).to be_instance_of(Proceeding)
    end

    it "returns da004 as the last item" do
      item = subject.last
      expect(item).to be_an_instance_of(LegalAidApplication::ProceedingStruct)
      expect(item.name).to eq "nonmolestation_order"
      expect(item.meaning).to eq "Non-molestation order"
      expect(item.proceeding).to be_instance_of(Proceeding)
    end
  end

  describe "lowest_chances_of_success" do
    it "returns text representation of the lowest chance of success" do
      laa = create :legal_aid_application, :with_proceedings, proceeding_count: 3
      prospects = %w[likely borderline marginal]
      laa.proceedings.each_with_index do |proceeding, i|
        proceeding.chances_of_success = create(:chances_of_success, proceeding:,
                                                                    success_prospect: prospects[i])
      end
      expect(laa.lowest_prospect_of_success).to eq "Borderline"
    end
  end

  describe "required_document_categories" do
    let(:laa) { create :legal_aid_application }

    before { allow(DocumentCategory).to receive(:displayable_document_category_names).and_return %w[benefit_evidence gateway_evidence] }

    it "defaults to an empty array" do
      expect(laa.required_document_categories).to eq []
    end

    it "allows a valid document category to be added" do
      laa.required_document_categories << "benefit_evidence"
      laa.save!
      expect(laa.required_document_categories).to eq %w[benefit_evidence]
    end

    it "allows multiple valid document categories to be added" do
      laa.required_document_categories = %w[gateway_evidence benefit_evidence]
      laa.save!
      expect(laa.required_document_categories).to eq %w[gateway_evidence benefit_evidence]
    end

    it "errors when an invalid document category is added" do
      laa.required_document_categories << "invalid_evidence"
      expect { laa.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "#section_8_proceedings?" do
    context "with section 8 proceedings" do
      let(:laa) { create :legal_aid_application, :with_multiple_proceedings_inc_section8 }

      it "returns true" do
        expect(laa.section_8_proceedings?).to be true
      end
    end

    context "without section 8 proceedings" do
      let(:laa) { create :legal_aid_application }
      let!(:proceeding) { create :proceeding, :da001, legal_aid_application: laa }

      it "returns false" do
        expect(laa.section_8_proceedings?).to be false
      end
    end
  end

  describe "#online_current_accounts_balance" do
    let(:laa) { create :legal_aid_application, :with_applicant }

    context "with no current accounts" do
      it "returns nil" do
        expect(laa.online_current_accounts_balance).to be_nil
      end
    end

    context "with bank accounts" do
      let(:balance1) { BigDecimal(rand(1...1_000_000.0), 2) }
      let(:balance2) { BigDecimal(rand(1...1_000_000.0), 2) }
      let(:bank_provider) { create :bank_provider, applicant: laa.applicant }

      before do
        create :bank_account, bank_provider: bank_provider, account_type: account_type, balance: balance1
        create :bank_account, bank_provider:, account_type:, balance: balance2
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
    let(:laa) { create :legal_aid_application, :with_applicant }

    context "with no current accounts" do
      it "returns nil" do
        expect(laa.online_savings_accounts_balance).to be_nil
      end
    end

    context "with bank accounts" do
      let(:balance1) { BigDecimal(rand(1...1_000_000.0), 2) }
      let(:balance2) { BigDecimal(rand(1...1_000_000.0), 2) }
      let(:bank_provider) { create :bank_provider, applicant: laa.applicant }

      before do
        create :bank_account, bank_provider: bank_provider, account_type: "SAVINGS", balance: balance1
        create :bank_account, bank_provider:, account_type: "SAVINGS", balance: balance2
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
      let(:laa) { create(:legal_aid_application, :with_multiple_employments) }

      it "returns true" do
        expect(laa.hmrc_employment_income?).to be true
      end
    end
  end

  describe "uploaded_evidence_by_category" do
    let(:laa) { create :legal_aid_application }
    let!(:evidence) { create :uploaded_evidence_collection, :with_multiple_evidence_types_attached, legal_aid_application: laa }

    before { DocumentCategory.populate }

    context "when no evidence has been uploaded" do
      before { laa.uploaded_evidence_collection = nil }

      it "returns nil" do
        expect(laa.uploaded_evidence_by_category).to be_nil
      end
    end

    context "when evidence has been uploaded" do
      it "returns a hash of evidence filenames grouped by category" do
        deep_match(laa.uploaded_evidence_by_category, uploaded_evidence_output)
      end
    end
  end

  describe "manually_entered_employment_information?" do
    let(:laa) { create :legal_aid_application }

    context "when no employment information has been entered by the provider" do
      it "returns false" do
        expect(laa.manually_entered_employment_information?).to be false
      end
    end

    context "when extra employment information has been entered by the provider" do
      before do
        laa.update!(extra_employment_information: true)
        laa.update!(extra_employment_information_details: "test details")
      end

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

    describe "#hmrc_response_use_case_one" do
      let(:laa) { create :legal_aid_application }
      let!(:use_case_one) { create :hmrc_response, :use_case_one, legal_aid_application: laa }
      let!(:use_case_two) { create :hmrc_response, :use_case_two, legal_aid_application: laa }

      it "returns the use case one record" do
        expect(laa.hmrc_response_use_case_one).to eq use_case_one
      end
    end

    describe "#eligible_employment_payments" do
      let(:laa) { create :legal_aid_application, :with_transaction_period }

      context "with one employment with employment payments" do
        before do
          emp = create :employment, legal_aid_application: laa
          create :employment_payment, employment: emp, date: 1.month.ago
          create :employment_payment, employment: emp, date: 2.months.ago
        end

        it "returns two employment records" do
          payments = laa.eligible_employment_payments
          expect(payments.size).to eq 2
          expect(payments.map(&:class).uniq).to eq [EmploymentPayment]
        end
      end

      context "with one employment with no employment payments" do
        before { create :employment, legal_aid_application: laa }

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
          emp1 = create :employment, legal_aid_application: laa
          create :employment_payment, employment: emp1, date: 1.month.ago
          create :employment_payment, employment: emp1, date: 2.months.ago
          emp2 = create :employment, legal_aid_application: laa
          create :employment_payment, employment: emp2, date: 1.month.ago
        end

        it "returns one collection of three records" do
          expect(laa.eligible_employment_payments.size).to eq 3
        end
      end

      context "with all payments before start of transaction period" do
        before do
          emp1 = create :employment, legal_aid_application: laa
          create :employment_payment, employment: emp1, date: laa.transaction_period_start_on - 3.days
          create :employment_payment, employment: emp1, date: laa.transaction_period_start_on - 10.days
          emp2 = create :employment, legal_aid_application: laa
          create :employment_payment, employment: emp2, date: laa.transaction_period_start_on - 1.month
        end

        it "returns an empty collection" do
          expect(laa.eligible_employment_payments).to be_empty
        end
      end

      context "with one payment in transaction period, others before" do
        before do
          emp1 = create :employment, legal_aid_application: laa
          create :employment_payment, employment: emp1, date: laa.transaction_period_start_on - 3.days
          create :employment_payment, employment: emp1, date: laa.transaction_period_start_on + 2.days
          create :employment_payment, employment: emp1, date: laa.transaction_period_start_on - 10.days
        end

        it "returns a collection of just the one record in the transaction period" do
          expect(laa.eligible_employment_payments.size).to eq 1
        end
      end
    end

    describe "#uploading_bank_statements?" do
      let(:laa) { create :legal_aid_application, provider:, provider_received_citizen_consent: consent }

      context "when provider does not have bank statement upload role" do
        let(:provider) { create :provider }
        let(:consent) { nil }

        it "returns false" do
          expect(laa.uploading_bank_statements?).to be false
        end
      end

      context "when provider has bank statement upload role" do
        let(:provider) { create :provider, :with_bank_statement_upload_permissions }

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
    end

    describe "#has_transaction_type?" do
      subject { laa.has_transaction_type?(transaction_type) }

      let!(:benefits) { create(:transaction_type, :benefits) }
      let!(:rent_or_mortgage) { create(:transaction_type, :rent_or_mortgage) }

      context "when application has that transaction type" do
        let(:laa) { create :legal_aid_application, transaction_types: [benefits] }
        let(:transaction_type) { benefits }

        it { is_expected.to be_truthy }
      end

      context "when application does not have that transaction type" do
        let(:laa) { create :legal_aid_application, transaction_types: [benefits] }
        let(:transaction_type) { rent_or_mortgage }

        it { is_expected.to be_falsey }
      end

      context "when application does not have any transaction types" do
        let(:laa) { create :legal_aid_application, transaction_types: [] }
        let(:transaction_type) { benefits }

        it { is_expected.to be_falsey }
      end
    end
  end

private

  def uploaded_evidence_output
    {
      "benefit_evidence" => ["Fake Benefit Evidence 1", "Fake Benefit Evidence 2"],
      "gateway_evidence" => ["Fake Gateway Evidence 1", "Fake Gateway Evidence 2"],
    }
  end

  def deep_match(actual, expected)
    expect(actual.keys.sort).to eq expected.keys.sort
    actual.each do |key, ids|
      expect(ids).to match_array(expected[key])
    end
  end
end
