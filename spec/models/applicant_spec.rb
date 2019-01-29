require 'rails_helper'

RSpec.describe Applicant, type: :model do
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
