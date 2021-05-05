require 'rails_helper'

RSpec.describe ProceedingTypeScopeLimitationsPopulator do
  before(:all) do
    # TODO: Un-comment when the allow_multiple_proceedings? flag is removed
    # ProceedingTypePopulator.call
    ServiceLevelPopulator.call
    ScopeLimitationsPopulator.call
  end
  # TODO: Delete when the allow_multiple_proceedings? flag is removed
  before do
    allow(Setting).to receive(:allow_multiple_proceedings?).and_return(multi_proc_flag)
    ProceedingTypePopulator.call
  end
  let(:multi_proc_flag) { true }

  after(:all) do
    DatabaseCleaner.clean_with :truncation
  end

  describe '#call' do
    let(:seed_file) { Rails.root.join('db/seeds/legal_framework/proceeding_type_scope_limitations.csv') }
    let(:proceeding_type_scope_limitation) { ProceedingTypeScopeLimitation.order('created_at ASC').first }
    let(:expected_proceeding_type_id) { ProceedingType.find_by(ccms_code: CSV.read(seed_file, headers: true)[0][0]).id }
    let(:expected_scope_limitation_id) { ScopeLimitation.find_by(code: CSV.read(seed_file, headers: true)[0][1]).id }

    it 'create instances from the seed file' do
      expect { described_class.call }.to change { ProceedingTypeScopeLimitation.count }.by(seed_file.readlines.size - 1)
    end

    it 'creates an instance with correct proceeding_type_id and scope_limitation_id' do
      described_class.call
      expect(proceeding_type_scope_limitation.proceeding_type_id).to eq(expected_proceeding_type_id)
      expect(proceeding_type_scope_limitation.scope_limitation_id).to eq(expected_scope_limitation_id)
    end

    context 'when a proceeding_type_scope_limitation combination already exists' do
      let!(:existing_scope_limitation) do
        ProceedingTypeScopeLimitation.create(proceeding_type_id: expected_proceeding_type_id,
                                             scope_limitation_id: expected_scope_limitation_id,
                                             substantive_default: false,
                                             delegated_functions_default: false)
      end

      it 'creates one less proceeding_type_scope_limitation' do
        expect { described_class.call }.to change { ProceedingTypeScopeLimitation.count }.by(seed_file.readlines.size - 2)
      end
    end

    context 'when run twice' do
      it 'creates the same total number of proceeding_type_scope_limitations' do
        expect {
          described_class.call
          described_class.call
        }.to change { ProceedingTypeScopeLimitation.count }.by(seed_file.readlines.size - 1)
      end
    end

    # TODO: Delete when the allow_multiple_proceedings? flag is removed
    context 'when the multi-proceeding flag is false' do
      let(:multi_proc_flag) { false }

      it 'create non-flagged instances from the seed file' do
        expect { described_class.call }.to change { ProceedingTypeScopeLimitation.count }.by(77)
      end
    end
  end
end
