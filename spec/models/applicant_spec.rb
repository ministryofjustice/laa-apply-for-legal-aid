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

  it 'is not valid without a first name' do
    subject.first_name = ''
    expect(subject).to_not be_valid
    expect(subject.errors[:first_name]).to include("can't be blank")
  end

  it 'is not valid without a last name' do
    subject.last_name = ''
    expect(subject).to_not be_valid
    expect(subject.errors[:last_name]).to include("can't be blank")
  end

  it 'is not valid without a date of birth' do
    subject.date_of_birth = nil
    expect(subject).to_not be_valid
    expect(subject.errors[:date_of_birth]).to include("can't be blank")
  end

  it 'is not valid if the date of birth is in the future' do
    subject.date_of_birth = Date.today + 1
    expect(subject).to_not be_valid
  end

  it 'is not valid if the date of birth is before 1900-01-01' do
    subject.date_of_birth = Date.new(1899, 12, 31)
    expect(subject).to_not be_valid
  end

  it 'is not valid if the email entered is not in the correct form' do
    subject.email = 'asdfgh'
    expect(subject).to_not be_valid
    expect(subject.errors[:email]).to include('address is not in the right format')
  end

  it 'is valid when the email address provided is in the correct format' do
    subject.email = 'test@test.com'
    expect(subject).to be_valid
  end

  it 'is valid when email address is not provided' do
    subject.email = nil
    expect(subject).to be_valid
  end

  it 'is not valid when a national insurance number is not provided' do
    subject.national_insurance_number = nil
    expect(subject).to_not be_valid
    expect(subject.errors[:national_insurance_number]).to include("can't be blank")
  end

  it 'is not valid if the national insurance number entered is not in the correct form' do
    subject.national_insurance_number = 'QQ12AS23RR'
    expect(subject).to_not be_valid
    expect(subject.errors[:national_insurance_number]).to include('is not in the right format')
  end

  context 'with test national insurance numbers' do
    let(:test_ninos) do
      # from https://dsdmoj.atlassian.net/wiki/spaces/ATPPB/pages/1298464776/Benefit+Checker
      %w[
        MR542366A PW556356A JL304175D PW312175D JL806367D GH293483B NW764948B NY035863D JA293483B JN287640A JC383483D
        JA293483D SG867619D JS130161E JK545019A JT351585B NX794801E JD142369D JA293483A YZ034627C RZ993038C NH293825D
        JC954254C NP685623E NP414146D JR468684E JG523654B JB827361B JT457442B JR418836A JW953007D JM287146A JF982354B
        JK806648E JE900506A JA827364A JW570102E
      ]
    end

    let(:nino_match) do
      test_ninos.map { |nino|
        applicant = build(:applicant, national_insurance_number: nino)
        applicant.valid? ? nil : nino
      }.compact
    end

    context 'with normal validation' do
      before do
        allow(Rails.configuration.x.applicant).to receive(:test_level_nino_validation).and_return('false')
      end
      it 'some are invalid' do
        expect(nino_match).not_to be_empty
      end
    end

    context 'with test level validation' do
      before do
        allow(Rails.configuration.x.applicant).to receive(:test_level_nino_validation).and_return('true')
      end
      it 'none are invalid' do
        expect(nino_match).to be_empty
      end

      it 'does not affect other checks' do
        subject.national_insurance_number = 'QQ12AS23RR'
        expect(subject).to_not be_valid
      end
    end
  end

  context 'with an existing applicant' do
    let!(:existing_applicant) { create :applicant }

    it 'allows another applicant to be created with same email' do
      expect { create :applicant, email: existing_applicant.email }.to change { Applicant.count }.by(1)
    end
  end

  context '#dob' do
    let(:year) { 1990 }
    let(:month) { 12 }
    let(:day) { 12 }
    let(:dob) { Date.new(year, month, day) }
    let(:existing_applicant) { create :applicant, date_of_birth: dob }
    let(:subject_dob_hash) { existing_applicant.dob }
    let(:dob_hash) do
      {
        dob_year: year.to_s,
        dob_month: month.to_s,
        dob_day: day.to_s
      }
    end

    it 'returns hash with dob_year' do
      expect(subject_dob_hash[:dob_year]).to eq(year.to_s)
    end

    it 'returns hash with dob_month' do
      expect(subject_dob_hash[:dob_month]).to eq(month.to_s)
    end

    it 'returns hash with dob_day' do
      expect(subject_dob_hash[:dob_day]).to eq(day.to_s)
    end

    it 'returns hash with following keys' do
      expect(subject_dob_hash).to include(:dob_year, :dob_month, :dob_day)
    end
  end
end
