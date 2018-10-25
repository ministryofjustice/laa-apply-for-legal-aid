require 'rails_helper'

RSpec.describe Applicants::EmailForm, type: :form do
  describe '.model_name' do
    it 'should be "Applicant"' do
      expect(described_class.model_name).to eq('Applicant')
    end
  end

  let(:email_address) { Faker::Internet.safe_email }
  let(:applicant) { create :applicant, email_address: nil }
  let(:legal_aid_application) { create :legal_aid_application, applicant: applicant }

  let(:params) do
    {
      email_address: email_address,
      model: applicant
    }
  end

  subject { described_class.new(params) }

  describe '#save' do
    before do
      subject.save
      applicant.reload
    end

    it 'updates the email address' do
      expect(applicant.email_address).to eq(email_address)
    end

    context 'with an invalid email' do
      let(:email_address) { 'invalid' }

      it 'does not update the email address' do
        expect(applicant.email_address).not_to eq(email_address)
      end

      it 'address errors' do
        expect(subject.errors[:email_address]).to be_present
      end
    end
  end
end
