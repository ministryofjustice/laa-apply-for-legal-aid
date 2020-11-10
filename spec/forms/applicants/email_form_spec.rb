require 'rails_helper'

RSpec.describe Applicants::EmailForm, type: :form do
  describe '.model_name' do
    it 'should be "Applicant"' do
      expect(described_class.model_name).to eq('Applicant')
    end
  end

  let(:email) { Faker::Internet.safe_email }
  let(:applicant) { create :applicant, email: nil }
  let(:legal_aid_application) { create :legal_aid_application, applicant: applicant }

  let(:params) do
    {
      email: email,
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
      expect(applicant.email).to eq(email)
    end

    context 'with an invalid email' do
      let(:email) { 'invalid' }

      it 'does not update the email address' do
        expect(applicant.email).not_to eq(email)
      end

      it 'address errors' do
        expect(subject.errors[:email]).to be_present
      end
    end

    context 'stripping whitespace' do
      let(:fake_email_address) { Faker::Internet.safe_email }
      let(:email) { "  #{fake_email_address}  " }
      it 'updates the applicant email with the email address without whitespece' do
        subject.save
        expect(applicant.reload.email).to eq fake_email_address
      end
    end
  end
end
