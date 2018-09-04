require 'rails_helper'
require 'save_applicant'

RSpec.describe SaveApplicant do
  let(:valid_name) { 'Rich' }
  let(:valid_dob) { '1991-12-01' }

  context 'When given valid values' do
    it 'should save the model' do
      applicant, success = described_class.call(name: valid_name, date_of_birth: valid_dob)
      expect(success).to eq true
      expect(applicant.name).to eq valid_name
    end
  end
end
