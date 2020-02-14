require 'rails_helper'

RSpec.describe SecureApplicationFinder do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:expired_at) { 1.hour.from_now }
  let(:secure_data_id) do
    SecureData.create_and_store!(
      legal_aid_application: { id: legal_aid_application.id },
      expired_at: expired_at
    )
  end
  subject { described_class.new(secure_data_id) }

  it 'finds the application' do
    expect(subject.legal_aid_application).to eq(legal_aid_application)
  end

  it 'has no errors' do
    expect(subject.error).to be_nil
  end

  context 'when expired' do
    let(:expired_at) { 1.hour.ago }

    it 'does not find the application' do
      expect(subject.legal_aid_application).to eq(legal_aid_application)
    end

    it 'has :expired error' do
      expect(subject.error).to eq(:expired)
    end
  end
end
