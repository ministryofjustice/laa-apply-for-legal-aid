require 'rails_helper'

RSpec.describe ProceedingTypeScopeLimitation, type: :model do
  let(:proceeding_type) { create :proceeding_type }
  let(:scope_limitation) { create :scope_limitation }
  let(:proceeding_type_scope_limitation) { ProceedingTypeScopeLimitation.create(proceeding_type: proceeding_type, scope_limitation: scope_limitation) }

  it 'should belong to a proceeding_type and a scope_limitation' do
    expect(proceeding_type_scope_limitation.proceeding_type_id).not_to be_nil
    expect(proceeding_type_scope_limitation.proceeding_type_id).to eq(proceeding_type.id)
    expect(proceeding_type_scope_limitation.scope_limitation_id).not_to be_nil
    expect(proceeding_type_scope_limitation.scope_limitation_id).to eq(scope_limitation.id)
  end

  describe 'should have associations with proceeding_type and scope_limitation' do
    it { should belong_to(:proceeding_type) }
    it { should belong_to(:scope_limitation) }
  end

  describe '.populate' do
    it 'calls the scope_limitations_populator service' do
      expect(ProceedingTypeScopeLimitationsPopulator).to receive(:call).with(no_args)
      described_class.populate
    end
  end
end
