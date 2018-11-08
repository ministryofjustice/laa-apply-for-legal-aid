require 'rails_helper'

RSpec.describe LegalAidApplication, type: :model do
  let(:attributes) { {} }

  subject(:application) { described_class.new(attributes) }

  it { is_expected.to belong_to(:applicant) }
  it { is_expected.to have_many(:proceeding_types) }

  it 'is valid with all valid attributes' do
    expect(application).to be_valid
  end

  describe 'validations' do
    context 'when invalid proceeding type codes are provided' do
      let(:attributes) { { proceeding_type_codes: %w[invalid_code1 invalid_code2] } }

      it 'contains an invalid error for proceeding type codes' do
        expect(application).not_to be_valid
        expect(application.errors[:proceeding_type_codes]).to match_array(['is invalid'])
      end
    end

    context 'when valid proceeding type codes are provided' do
      let!(:proceeding_types) { create_list(:proceeding_type, 2) }
      let(:proceeding_type_codes) { proceeding_types.map(&:code) }
      let(:attributes) { { proceeding_type_codes: proceeding_type_codes } }

      it { is_expected.to be_valid }
    end
  end

  describe '#proceeding_type_codes=' do
    context 'when all the provded codes match existent proceeding types' do
      let!(:proceeding_types) { create_list(:proceeding_type, 2) }
      let(:proceeding_type_codes) { proceeding_types.map(&:code) }

      it 'assigns the provides codes' do
        expect {
          application.proceeding_type_codes = proceeding_type_codes
        }.to change { application.proceeding_type_codes }.from(nil).to(proceeding_type_codes)
      end

      it 'assign all providing types matching the codes' do
        expect(application.proceeding_types).to be_empty
        application.proceeding_type_codes = proceeding_type_codes
        expect(application.proceeding_types).to eq(proceeding_types)
      end
    end

    context 'when not all the provided codes match existent proceeding types' do
      let!(:proceeding_type) { create(:proceeding_type) }
      let(:proceeding_type_codes) { [proceeding_type.code, 'non-existent-code'] }

      it 'assigns the provides codes' do
        expect {
          application.proceeding_type_codes = proceeding_type_codes
        }.to change { application.proceeding_type_codes }.from(nil).to(proceeding_type_codes)
      end

      it 'assign only the providing types matching the codes' do
        expect(application.proceeding_types).to be_empty
        application.proceeding_type_codes = proceeding_type_codes
        expect(application.proceeding_types).to eq([proceeding_type])
      end
    end
  end

  describe '#add_benefit_check_result' do
    let(:benefit_check_service) { spy(BenefitCheckService) }
    let(:benefit_check_response) do
      {
        benefit_checker_status: Faker::Lorem.word,
        confirmation_ref: SecureRandom.hex
      }
    end

    before do
      application.save!
      allow(BenefitCheckService).to receive(:new).with(application).and_return(benefit_check_service)
    end

    it 'creates a check_benefit_result with the right values' do
      expect(benefit_check_service).to receive(:call).and_return(benefit_check_response)

      application.add_benefit_check_result
      expect(application.benefit_check_result.result).to eq(benefit_check_response[:benefit_checker_status])
      expect(application.benefit_check_result.dwp_ref).to eq(benefit_check_response[:confirmation_ref])
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

    it 'generates data that can be used to find application' do
      id = subject
      secure_data = SecureData.find(id)
      expect(described_class.find_by(secure_data.retrieve)).to eq(legal_aid_application)
    end
  end
end
