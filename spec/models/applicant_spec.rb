require 'rails_helper'

RSpec.describe Applicant, type: :model do
  describe 'on validation' do
    subject { described_class.new }

    before do
      subject.first_name = 'John'
      subject.last_name = 'Doe'
      subject.date_of_birth = Date.new(1988, 0o2, 0o1)
      subject.national_insurance_number = 'AB123456D'
    end

    it 'is valid with all valid attributes' do
      expect(subject).to be_valid
    end

    context 'with an existing applicant' do
      let!(:existing_applicant) { create :applicant }

      it 'allows another applicant to be created with same email' do
        expect { create :applicant, email: existing_applicant.email }.to change { Applicant.count }.by(1)
      end
    end
  end

  # Main purpose: to ensure relationships to other object set so that destroying applicant destroys all objects
  # that then become redundant.
  describe '.destroy_all' do
    let!(:applicant) { create :applicant, :with_address }
    let!(:legal_aid_application) { create :legal_aid_application, applicant: applicant }
    # Creating a bank transaction creates an applicant and the objects between it and the transaction
    let!(:bank_transaction) { create :bank_transaction }
    let(:bank_provider) { bank_transaction.bank_account.bank_provider }
    let!(:bank_account_holder) { create :bank_account_holder, bank_provider: bank_provider }
    let!(:bank_error) { create :bank_error, applicant: applicant }

    subject { described_class.destroy_all }

    it 'removes everything it needs to' do
      expect(Applicant.count).not_to be_zero
      expect(Address.count).not_to be_zero
      expect(BankProvider.count).not_to be_zero
      expect(BankTransaction.count).not_to be_zero
      expect(LegalAidApplication.count).not_to be_zero
      expect(BankAccountHolder.count).not_to be_zero
      expect(BankError.count).not_to be_zero
      subject
      expect(Applicant.count).to be_zero
      expect(Address.count).to be_zero
      expect(BankProvider.count).to be_zero
      expect(BankTransaction.count).to be_zero
      expect(LegalAidApplication.count).to be_zero
      expect(BankAccountHolder.count).to be_zero
      expect(BankError.count).to be_zero
    end
  end

  context 'True Layer Token' do
    let(:token) { SecureRandom.uuid }
    # Note - JSON time doesn't include micro seconds so need to round to second to get consistent result
    let(:token_expires_at) { 10.minutes.from_now.round(0) }
    let(:data) { { token: token, expires: token_expires_at } }
    let(:applicant) { create :applicant }

    subject { applicant.store_true_layer_token token: token, expires: token_expires_at }

    it 'stores the data securely' do
      expect { subject }.to change { SecureData.count }.by(1)
    end

    it 'associates the applicant with the secure data' do
      subject
      expect(applicant.true_layer_secure_data_id).to eq(SecureData.last.id)
    end

    describe '#true_layer_token' do
      it 'returns the original token' do
        subject
        expect(applicant.true_layer_token).to eq(token)
      end
    end

    describe '#true_layer_token_expires_at' do
      it 'returns the original expiry time' do
        subject
        expect(applicant.true_layer_token_expires_at).to eq(token_expires_at)
      end
    end
  end

  describe '#age' do
    let(:legal_aid_application) { build :legal_aid_application, :with_transaction_period, :with_applicant }
    subject { legal_aid_application.applicant.age }

    it 'returns the age of the applicant' do
      expect(subject).to be_kind_of(Integer)
    end
  end

  describe '#receives_financial_support?' do
    subject { legal_aid_application.applicant.receives_financial_support? }

    let(:applicant) { create :applicant }
    let(:bank_provider) { create :bank_provider, applicant: applicant }
    let(:bank_account) { create :bank_account, bank_provider: bank_provider }
    let!(:friends_or_family) { create :transaction_type, :credit, :friends_or_family }
    let(:benefits) { create :transaction_type, :credit, name: 'benefits' }
    let!(:benefits_bank_transaction) { create :bank_transaction, :credit, transaction_type: benefits, bank_account: bank_account }
    let(:legal_aid_application) { create :legal_aid_application, applicant: applicant, transaction_types: [benefits] }

    context 'when they receive friends and family income' do
      before { create :bank_transaction, :credit, transaction_type: friends_or_family, bank_account: bank_account }
      it { is_expected.to be true }
    end

    context 'when they do not receive friends and family income' do
      it { is_expected.to be false }
    end
  end

  context 'income checks' do
    let(:applicant) { create :applicant }
    let(:benefits) { create :transaction_type, :credit, name: 'benefits' }
    let(:transaction_array) { [benefits] }
    let(:legal_aid_application) { create :legal_aid_application, applicant: applicant, transaction_types: transaction_array }
    let!(:cfe_submission) { create :cfe_submission, legal_aid_application: legal_aid_application }

    describe '#receives_maintenance?' do
      subject { legal_aid_application.applicant.receives_maintenance? }

      context 'when they receive maintenance' do
        context 'with cfe version 3' do
          let!(:cfe_result) { create :cfe_v3_result, :with_maintenance_received, submission: cfe_submission }

          it { is_expected.to be true }
        end
        context 'with cfe version 4 result' do
          let!(:cfe_result) { create :cfe_v4_result, :with_maintenance_received, submission: cfe_submission }

          it { is_expected.to be true }
        end
      end

      context 'when they do not receive maintenance' do
        context 'with cfe version 3' do
          let!(:cfe_result) { create :cfe_v3_result, submission: cfe_submission }

          it { is_expected.to be false }
        end
        context 'with cfe version 4 result' do
          let!(:cfe_result) { create :cfe_v4_result, submission: cfe_submission }

          it { is_expected.to be false }
        end
      end
    end

    describe '#maintenance_per_month' do
      subject { legal_aid_application.applicant.maintenance_per_month }

      context 'when they receive maintenance' do
        context 'with cfe version 3' do
          let!(:cfe_result) { create :cfe_v3_result, :with_maintenance_received, submission: cfe_submission }

          it { is_expected.to eq '150.00' }
        end
        context 'with cfe version 4 result' do
          let!(:cfe_result) { create :cfe_v4_result, :with_maintenance_received, submission: cfe_submission }

          it { is_expected.to eq '150.00' }
        end
      end

      context 'when they do not receive maintenance' do
        context 'with cfe version 3' do
          let!(:cfe_result) { create :cfe_v3_result, submission: cfe_submission }

          it { is_expected.to eq '0.00' }
        end
        context 'with cfe version 4 result' do
          let!(:cfe_result) { create :cfe_v4_result, submission: cfe_submission }

          it { is_expected.to eq '0.00' }
        end
      end
    end
  end

  describe '#mortgage_per_month' do
    let(:legal_aid_application) { create :legal_aid_application, :with_everything }
    let(:cfe_submission) { create :cfe_submission, legal_aid_application: legal_aid_application }
    subject { legal_aid_application.applicant.mortgage_per_month }

    context 'when they pay a mortgage' do
      context 'with cfe version 3 result' do
        let!(:cfe_result) { create :cfe_v3_result, submission: cfe_submission }

        it { is_expected.to eq '125.00' }

        context 'when they do not pay a mortgage' do
          let!(:cfe_result) { create :cfe_v4_result, submission: cfe_submission }

          it { is_expected.to eq '0.00' }
        end
      end
      context 'with cfe version 4 result' do
        let!(:cfe_result) { create :cfe_v4_result, :with_mortgage_costs, submission: cfe_submission }

        it { is_expected.to eq '120.00' }

        context 'when they do not pay a mortgage' do
          let!(:cfe_result) { create :cfe_v4_result, submission: cfe_submission }

          it { is_expected.to eq '0.00' }
        end
      end
    end
  end

  describe '#valid_cfe_result_version?' do
    let(:applicant) { create :applicant }

    context 'with CFE version 3 result' do
      let!(:legal_aid_application) { create :legal_aid_application, :with_cfe_v3_result, applicant: applicant }

      it 'returns true' do
        expect(applicant.valid_cfe_result_version?).to eq true
      end
    end
    context 'with CFE version 4 result' do
      let!(:legal_aid_application) { create :legal_aid_application, :with_cfe_v4_result, applicant: applicant }

      it 'returns true' do
        expect(applicant.valid_cfe_result_version?).to eq true
      end
    end

    context 'with CFE version out of scope result' do
      let!(:legal_aid_application) { create :legal_aid_application, applicant: applicant }
      let(:cfe_version_5_result) { double 'CFE::V5::Result' }

      before do
        allow_any_instance_of(Applicant).to receive(:cfe_result_type).and_return(cfe_version_5_result)
      end

      it 'returns false' do
        expect(applicant.valid_cfe_result_version?).to eq false
      end
    end
  end
end
