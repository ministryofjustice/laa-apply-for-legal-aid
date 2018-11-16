require 'rails_helper'

RSpec.describe SecureData, type: :model do
  let(:secure_data) { create :secure_data }
  let(:data) { { foo: 'bar' } }

  describe '.create_and_store!' do
    let(:secure_data) { described_class.last }
    subject { described_class.create_and_store!(data) }

    it 'creates a new instance' do
      expect { subject }.to change { described_class.count }
    end

    it 'returns the id of the new instance' do
      expect(subject).to eq(secure_data.id)
    end

    it 'stores the data in the new instance' do
      subject
      expect(secure_data.retrieve).to eq(data)
    end
  end

  describe '.for' do
    it 'retrieves matching data' do
      expect(described_class.for(secure_data.id)).to eq(secure_data.retrieve)
    end
  end

  describe '#store' do
    subject { secure_data.store(data) }

    it 'changes the data' do
      expect { subject }.to change { secure_data.data }
    end

    it 'does not match the data' do
      subject
      expect(data).not_to match(secure_data.data)
    end
  end

  describe '#retrieve' do
    it 'retrieves stored data' do
      secure_data.store(data)
      expect(secure_data.retrieve).to eq(data)
    end

    it 'raises errors if data tampered with' do
      subject
      secure_data.update data: JWT.encode(secure_data.data, 'invalid', 'HS256')
      expect { secure_data.retrieve }.to raise_error(JWT::VerificationError)
    end
  end
end
