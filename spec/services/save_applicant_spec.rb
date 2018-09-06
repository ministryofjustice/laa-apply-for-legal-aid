require 'rails_helper'

RSpec.describe SaveApplicant do
  let(:name) { 'Rich' }
  let(:date_of_birth) { '1991-12-01' }
  let(:existing_application) {LegalAidApplication.create}
  let(:application_ref) {existing_application.application_ref}

  context 'When given valid values' do
    it 'should save the model' do
      applicant, success = described_class.call(name: name, date_of_birth: date_of_birth, application_ref: application_ref )
      expect(success).to eq true
      expect(existing_application.reload.applicant).to eq applicant
      expect(applicant.name).to eq name
    end
  end

  context 'When given invalid values' do
    let(:date_of_birth) {"11-11-11"}
    it 'should throw an error' do
      errors, success = described_class.call(name: name, date_of_birth: date_of_birth, application_ref: application_ref )
      expect(success).to eq false
      expect(existing_application.reload.applicant).to be_nil
      expect(errors).to match(['invalid application reference'])
    end
    it 'does not create a new applicant record' do
      expect {described_class.call(name: name, date_of_birth: date_of_birth, application_ref: application_ref )}.not_to change {Applicant.count}
    end
  end

  context 'When given an invalid application reference' do
    let(:application_ref) {SecureRandom.uuid}
    it 'should throw an error' do
      errors, success = described_class.call(name: name, date_of_birth: date_of_birth, application_ref: application_ref )
      expect(success).to eq false
      expect(errors).to match(['invalid application reference'])
    end

    it 'does not create a new applicant record' do
      expect {described_class.call(name: name, date_of_birth: date_of_birth, application_ref: application_ref )}.not_to change {Applicant.count}
    end
  end
end
