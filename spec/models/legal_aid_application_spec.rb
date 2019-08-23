require 'rails_helper'

RSpec.describe LegalAidApplication, type: :model do
  let(:legal_aid_application) { create :legal_aid_application }

  describe 'validations' do
    let(:attributes) { { proceeding_type_codes: %w[invalid_code1 invalid_code2] } }
    let(:legal_aid_application) { described_class.new(attributes) }
    context 'when invalid proceeding type codes are provided' do
      it 'contains an invalid error for proceeding type codes' do
        expect(legal_aid_application).not_to be_valid
        expect(legal_aid_application.errors[:proceeding_type_codes]).to match_array(['is invalid'])
      end
    end

    context 'when valid proceeding type codes are provided' do
      let!(:proceeding_types) { create_list(:proceeding_type, 2) }
      let(:proceeding_type_codes) { proceeding_types.map(&:code) }
      let(:attributes) { { provider: create(:provider), proceeding_type_codes: proceeding_type_codes } }

      it 'will be valid' do
        expect(legal_aid_application).to be_valid
      end
    end
  end

  describe '#proceeding_type_codes=' do
    context 'when all the provded codes match existent proceeding types' do
      let!(:proceeding_types) { create_list(:proceeding_type, 2) }
      let(:proceeding_type_codes) { proceeding_types.map(&:code) }

      it 'assigns the provides codes' do
        expect {
          legal_aid_application.proceeding_type_codes = proceeding_type_codes
        }.to change { legal_aid_application.proceeding_type_codes }.from(nil).to(proceeding_type_codes)
      end

      it 'assign all providing types matching the codes' do
        expect(legal_aid_application.proceeding_types).to be_empty
        legal_aid_application.proceeding_type_codes = proceeding_type_codes
        expect(legal_aid_application.proceeding_types).to eq(proceeding_types)
      end
    end

    context 'when not all the provided codes match existent proceeding types' do
      let!(:proceeding_type) { create(:proceeding_type) }
      let(:proceeding_type_codes) { [proceeding_type.code, 'non-existent-code'] }

      it 'assigns the provides codes' do
        expect {
          legal_aid_application.proceeding_type_codes = proceeding_type_codes
        }.to change { legal_aid_application.proceeding_type_codes }.from(nil).to(proceeding_type_codes)
      end

      it 'assign only the providing types matching the codes' do
        expect(legal_aid_application.proceeding_types).to be_empty
        legal_aid_application.proceeding_type_codes = proceeding_type_codes
        expect(legal_aid_application.proceeding_types).to eq([proceeding_type])
      end
    end
  end

  describe '#add_benefit_check_result' do
    let(:benefit_check_response) do
      {
        benefit_checker_status: Faker::Lorem.word,
        confirmation_ref: SecureRandom.hex
      }
    end

    before do
      legal_aid_application.save!
      allow(BenefitCheckService).to receive(:call).with(legal_aid_application).and_return(benefit_check_response)
    end

    it 'creates a check_benefit_result with the right values' do
      legal_aid_application.add_benefit_check_result
      expect(legal_aid_application.benefit_check_result.result).to eq(benefit_check_response[:benefit_checker_status])
      expect(legal_aid_application.benefit_check_result.dwp_ref).to eq(benefit_check_response[:confirmation_ref])
    end
  end

  describe 'benefit_check_result_needs_updating?' do
    let!(:legal_aid_application) { create :legal_aid_application, :with_applicant }
    let(:applicant) { legal_aid_application.applicant }
    it 'is true if no benefit check results' do
      expect(legal_aid_application).to be_benefit_check_result_needs_updating
    end

    context 'with up to date benefit check results' do
      let!(:benefit_check_result) { create :benefit_check_result, legal_aid_application: legal_aid_application }

      it 'returns false' do
        expect(legal_aid_application).not_to be_benefit_check_result_needs_updating
      end

      context 'but later, applicant first name updated' do
        before { applicant.update(first_name: Faker::Name.first_name) }

        it 'returns true' do
          expect(legal_aid_application).to be_benefit_check_result_needs_updating
        end
      end

      context 'but later, state changes' do
        before do
          legal_aid_application.check_your_answers!
        end

        it 'returns false' do
          expect(legal_aid_application).not_to be_benefit_check_result_needs_updating
        end
      end
    end
  end

  describe '#generate_secure_id' do
    let(:legal_aid_application) { create :legal_aid_application }
    let(:secure_data) { SecureData.last }

    subject { legal_aid_application.generate_secure_id }

    it 'generates a new secure data object' do
      expect { subject }.to change { SecureData.count }.by(1)
    end

    it 'returns the generated id' do
      expect(subject).to eq(secure_data.id)
    end

    it 'generates data that can be used to find legal_aid_application' do
      data = SecureData.for(subject)[:legal_aid_application]
      expect(data).to be_present
      expect(described_class.find_by(data)).to eq(legal_aid_application)
    end

    it 'generates data that contains a date which is in 8 days' do
      data = SecureData.for(subject)
      expire_date = (Time.current + LegalAidApplication::SECURE_ID_DAYS_TO_EXPIRE.days).end_of_day
      expect(data[:expired_at]).to be_between(expire_date - 1.minute, expire_date + 1.minute)
    end
  end

  describe 'state machine' do
    subject(:legal_aid_application) { create(:legal_aid_application) }

    it 'is created with a default state of "initiated"' do
      expect(legal_aid_application.state).to eq('initiated')
    end
  end

  describe '#shared_ownership?' do
    subject(:legal_aid_application) { create(:legal_aid_application, shared_ownership: shared_ownership_reason) }

    context 'when applicant owns a share of a property' do
      let(:shared_ownership_reason) { LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.first }

      it 'return true that the applicant owns a share of a property' do
        expect(legal_aid_application.shared_ownership?).to eq true
      end
    end

    context 'when applicant is the sole owner of a property' do
      let(:shared_ownership_reason) { LegalAidApplication::SHARED_OWNERSHIP_NO_REASONS.first }
      it 'return true that the applicant owns a share of a property' do
        expect(legal_aid_application.shared_ownership?).to eq false
      end
    end
  end

  describe '#own_home?' do
    context 'legal_aid_application.own_home is nil' do
      before { legal_aid_application.update!(own_home: nil) }
      it 'returns false' do
        expect(legal_aid_application.own_home?).to eq(false)
      end
    end

    context 'legal_aid_application.own_home is "no"' do
      let(:legal_aid_application) { create :legal_aid_application, :without_own_home }
      it 'returns false' do
        expect(legal_aid_application.own_home?).to eq(false)
      end
    end

    context 'legal_aid_application.own_home is not "no"' do
      let(:legal_aid_application) { create :legal_aid_application, :with_own_home_mortgaged }
      it 'returns true' do
        expect(legal_aid_application.own_home?).to eq(true)
      end
    end
  end

  describe '#own_capital?' do
    context 'no home, savings or assets' do
      let(:legal_aid_application) { create :legal_aid_application, own_home: nil }
      it 'returns nil' do
        expect(legal_aid_application.own_capital?).to be false
      end
    end

    context 'own home' do
      let(:legal_aid_application) { create :legal_aid_application, :with_own_home_mortgaged }
      it 'returns true' do
        expect(legal_aid_application.own_capital?).to eq(true)
      end
    end

    context 'has some assets' do
      before { legal_aid_application.update!(other_assets_declaration: create(:other_assets_declaration, :with_all_values)) }
      it 'returns true' do
        expect(legal_aid_application.own_capital?).to eq(true)
      end
    end

    context 'has some savings' do
      before { legal_aid_application.update!(savings_amount: create(:savings_amount, :with_values)) }
      it 'returns true' do
        expect(legal_aid_application.own_capital?).to eq(true)
      end
    end
  end

  describe '#passported?' do
    let(:legal_aid_application) { create :legal_aid_application, passported_value }  
    let(:passported_value) { :with_positive_benefit_check_result }

    it 'returns true' do
      expect(legal_aid_application.passported?).to be true
    end

    context 'with false benefit check result' do
      let(:passported_value) { :with_negative_benefit_check_result }

      it 'returns false' do
        expect(legal_aid_application.passported?).to be false
      end
    end
  end

  describe 'set_transaction_period' do
    subject { legal_aid_application.set_transaction_period }

    it 'sets start' do
      subject
      expect(legal_aid_application.transaction_period_start_on).to eq(Date.current - 3.months)
    end

    it 'sets finish' do
      subject
      expect(legal_aid_application.transaction_period_finish_on).to eq(Date.current)
    end

    context 'delegated functions are used' do
      let(:legal_aid_application) { create :legal_aid_application, used_delegated_functions: true, used_delegated_functions_on: Faker::Date.backward }
      let(:used_delegated_functions_on) { legal_aid_application.used_delegated_functions_on }

      it 'sets start and finish relative to used_delegated_functions_on' do
        subject
        expect(legal_aid_application.transaction_period_start_on).to eq(used_delegated_functions_on - 3.months)
        expect(legal_aid_application.transaction_period_finish_on).to eq(used_delegated_functions_on)
      end
    end
  end

  describe '#read_only?' do
    context 'provider application not submitted' do
      let(:legal_aid_application) { create :legal_aid_application }
      it 'returns false' do
        expect(legal_aid_application.read_only?).to be(false)
      end
    end

    context 'provider submitted' do
      let(:legal_aid_application) { create :legal_aid_application, :provider_submitted }
      it 'returns true' do
        expect(legal_aid_application.read_only?).to be(true)
      end
    end

    context 'checking citizen answers?' do
      let(:legal_aid_application) { create :legal_aid_application, state: :checking_citizen_answers }
      it 'returns true' do
        expect(legal_aid_application.read_only?).to be(true)
      end
    end
  end

  describe 'attributes are synced on client_details_answers_checked' do
    let(:legal_aid_application) { create :legal_aid_application, :with_everything, :without_own_home, state: :checking_client_details_answers }
    it 'passes application to keep in sync service' do
      expect(CleanupCapitalAttributes).to receive(:call).with(legal_aid_application)
      legal_aid_application.client_details_answers_checked!
    end

    context 'and attributes changed' do
      before do
        legal_aid_application.client_details_answers_checked!
        legal_aid_application.reload
      end
      it 'resets property values' do
        expect(legal_aid_application.property_value).to be_blank
      end
      it 'resets outstanding mortgage' do
        expect(legal_aid_application.outstanding_mortgage_amount).to be_blank
      end
      it 'resets shared ownership' do
        expect(legal_aid_application.shared_ownership).to be_blank
      end
      it 'resets percentage home' do
        expect(legal_aid_application.percentage_home).to be_blank
      end
    end
  end

  # Main purpose: to ensure relationships to other objects set so that destroying application destroys all objects
  # that then become redundant.
  describe '.destroy_all' do
    let!(:legal_aid_application) do
      create :legal_aid_application, :with_everything, :with_proceeding_types, :with_negative_benefit_check_result
    end

    before do
      create :legal_aid_application_transaction_type, legal_aid_application: legal_aid_application
    end

    subject { described_class.destroy_all }

    # A bit verbose, but minimises the SQL calls required to complete spec
    it 'removes everything it needs to' do
      expect(ApplicationProceedingType.count).not_to be_zero
      expect(BenefitCheckResult.count).not_to be_zero
      expect(OtherAssetsDeclaration.count).not_to be_zero
      expect(SavingsAmount.count).not_to be_zero
      expect(MeritsAssessment.count).not_to be_zero
      expect(StatementOfCase.count).not_to be_zero
      expect(LegalAidApplicationTransactionType.count).not_to be_zero
      expect { subject }.to change { described_class.count }.to(0)
      expect(ApplicationProceedingType.count).to be_zero
      expect(BenefitCheckResult.count).to be_zero
      expect(OtherAssetsDeclaration.count).to be_zero
      expect(SavingsAmount.count).to be_zero
      expect(MeritsAssessment.count).to be_zero
      expect(StatementOfCase.count).to be_zero
      expect(LegalAidApplicationTransactionType.count).to be_zero
    end

    it 'leaves object it should not affect' do
      expect(Applicant.count).not_to be_zero
      expect(ProceedingType.count).not_to be_zero
      expect(TransactionType.count).not_to be_zero
      subject
      expect(Applicant.count).not_to be_zero
      expect(ProceedingType.count).not_to be_zero
      expect(TransactionType.count).not_to be_zero
    end
  end

  describe '#create_app_ref' do
    it 'generates an application_ref when the application is created' do
      legal_aid_application = LegalAidApplication.create!(provider: (create :provider))
      expect(legal_aid_application.application_ref).to match(/L(-[ABCDEFHJKLMNPRTUVWXY0-9]{3}){2}/)
    end
  end

  describe 'state label' do
    let(:states) { LegalAidApplication.aasm.states.map(&:name) }

    it 'has a translation for all states' do
      states.each do |state|
        expect(I18n.exists?("model_enum_translations.legal_aid_application.state.#{state}")).to be(true)
      end
    end
  end

  describe '#wage_slips' do
    it 'returns the correct wage slip data' do
      expect(legal_aid_application.wage_slips).to eq []
    end
  end

  describe '#opponent_other_parties' do
    it 'returns the opponent other parties data' do
      expect(legal_aid_application.opponent_other_parties).to eq [Opponent.dummy_opponent]
    end
  end

  describe 'default_scope_limitation finding and adding' do
    let!(:proceeding_type) { create :proceeding_type }
    let!(:sl_substantive_default) { create :scope_limitation, :substantive_default, joined_proceeding_type: proceeding_type, meaning: 'Default substantive SL' }
    let!(:sl_delegated_default) { create :scope_limitation, :delegated_functions_default, joined_proceeding_type: proceeding_type, meaning: 'Default delegated functions SL' }
    let!(:sl_non_default) { create :scope_limitation }

    context 'substantive application' do
      let(:application) { create :legal_aid_application, proceeding_types: [proceeding_type] }

      context '#substantive and delegated functions scope limitations' do
        before do
          application.add_default_substantive_scope_limitation!
          application.update(used_delegated_functions: true)
          application.add_default_delegated_functions_scope_limitation!
        end

        describe 'substantive scope limitation' do
          it 'returns the substantive scope limitation' do
            expect(application.scope_limitations).to match_array [sl_substantive_default, sl_delegated_default]
            expect(application.substantive_scope_limitation).to eq sl_substantive_default
          end
        end

        describe 'delegated functions scope limitation' do
          it 'returns the delegated functions scope limitation' do
            expect(application.scope_limitations).to match_array [sl_substantive_default, sl_delegated_default]
            expect(application.delegated_functions_scope_limitation).to eq sl_delegated_default
          end
        end
      end
    end
  end

  describe 'reset delegated functions' do
    it 'resets it to a substantive application' do
      application = create :legal_aid_application, :with_delegated_functions
      expect(application.used_delegated_functions).to be true
      expect(application.used_delegated_functions_on).to eq Date.today
      application.reset_delegated_functions
      expect(application.used_delegated_functions).to be false
      expect(application.used_delegated_functions_on).to be_nil
    end
  end

  describe 'default_cost_limitations' do
    let(:proceeding_type) do
      create :proceeding_type,
             default_cost_limitation_substantive: 9_000,
             default_cost_limitation_delegated_functions: 2_500
    end
    context 'substantive' do
      let(:application) { create :legal_aid_application, proceeding_types: [proceeding_type] }
      it 'returns the substantive cost limitation for the first proceeding type' do
        expect(application.default_cost_limitation).to eq 9_000
      end
    end

    context 'delegated functions' do
      let(:application) { create :legal_aid_application, :with_delegated_functions,  proceeding_types: [proceeding_type] }
      it 'returns the delegated fucntions cost limitation for the first proceeding type' do
        expect(application.default_cost_limitation).to eq 2_500
      end
    end
  end

  describe '#bank_transactions' do
    let(:transaction_period_start_on) { '2019-08-10'.to_date }
    let(:transaction_period_finish_on) { '2019-08-20'.to_date }
    let(:date_before_start) { '2019-08-09 23:40 +0100'.to_time }
    let(:date_after_start)  { '2019-08-10 00:20 +0100'.to_time }
    let(:date_before_end)   { '2019-08-20 23:40 +0100'.to_time }
    let(:date_after_end)    { '2019-08-21 00:20 +0100'.to_time }
    let(:legal_aid_application) do
      create :legal_aid_application,
             :with_applicant,
             transaction_period_start_on: transaction_period_start_on,
             transaction_period_finish_on: transaction_period_finish_on
    end
    let(:bank_provider) { create :bank_provider, applicant: legal_aid_application.applicant }
    let(:bank_account) { create :bank_account, bank_provider: bank_provider }
    let!(:transaction_before_start) { create :bank_transaction, bank_account: bank_account, happened_at: date_before_start }
    let!(:transaction_after_start) { create :bank_transaction, bank_account: bank_account, happened_at: date_after_start }
    let!(:transaction_before_end) { create :bank_transaction, bank_account: bank_account, happened_at: date_before_end }
    let!(:transaction_after_end) { create :bank_transaction, bank_account: bank_account, happened_at: date_after_end }
    let(:transaction_ids) { subject.pluck(:id) }

    subject { legal_aid_application.bank_transactions }

    it 'returns the expected transactions' do
      expect(transaction_ids).to include(transaction_after_start.id)
      expect(transaction_ids).to include(transaction_before_end.id)

      expect(transaction_ids).not_to include(transaction_before_start.id)
      expect(transaction_ids).not_to include(transaction_after_end.id)
    end
  end
end
