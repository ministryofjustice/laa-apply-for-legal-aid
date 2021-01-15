require 'rails_helper'

RSpec.describe ProceedingTypesService do
  let!(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let!(:proceeding_type) { create :proceeding_type }
  let!(:default_substantive_scope_limitation) { create :scope_limitation, :substantive_default, joined_proceeding_type: proceeding_type, meaning: 'Default substantive SL' }

  subject { described_class.new(legal_aid_application) }

  describe '#add' do
    context 'correct params' do
      let(:scope_limitation) { :substantive }
      let(:params) do
        {
          proceeding_type_id: proceeding_type.id,
          scope_limitation: scope_limitation
        }
      end

      it 'adds a proceeding type' do
        subject.add(**params)
        expect(legal_aid_application.proceeding_types).to include(proceeding_type)
      end

      it 'calls AddScopeLimitationService' do
        expect(AddScopeLimitationService).to receive(:call).with(legal_aid_application, scope_limitation)
        subject.add(**params)
      end
    end

    context 'on failure' do
      let(:scope_limitation) { nil }
      let(:params) do
        {
          proceeding_type_id: proceeding_type.id,
          scope_limitation: scope_limitation
        }
      end

      it 'returns false' do
        expect(subject.add(**params)).to eq false
      end

      it 'does not call AddScopeLimitationService' do
        expect(AddScopeLimitationService).not_to receive(:call).with(legal_aid_application, scope_limitation)
        subject.add(**params)
      end
    end
  end
end
