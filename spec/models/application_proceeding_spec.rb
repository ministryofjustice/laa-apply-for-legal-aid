require 'rails_helper'
require 'spec_helper'

RSpec.describe ApplicationProceedingType, type: :model do
  subject { described_class.new }

  let!(:applicationProceedingType) { ApplicationProceedingType.create }

  it 'should belong to an proceeding_type and legal_aid_application' do
    expect(subject.legal_aid_application_id).to eq(applicationProceedingType.id)
    expect(subject.proceeding_type_id).to eq(applicationProceedingType.id)
  end
end
