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
end
