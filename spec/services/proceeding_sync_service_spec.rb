require 'rails_helper'

RSpec.describe ProceedingSyncService do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:proceeding_type) { create :proceeding_type, :with_scope_limitations }
  before do
    legal_aid_application.proceeding_types << proceeding_type
  end

  let(:sync_service) { described_class.new(legal_aid_application.application_proceeding_types.first) }

  describe '.create!' do
    it 'creates a corresponding proceeding record' do
      expect { sync_service.create! }.to change { Proceeding.count }.by 1
    end

    it 'populates the proceeding record with the correct data' do
      sync_service.create!

      proceeding = legal_aid_application.proceedings.first
      laa_proc = legal_aid_application.application_proceeding_types.first

      expect(proceeding.legal_aid_application_id).to eq legal_aid_application.id
      expect(proceeding.proceeding_case_id).to eq laa_proc.proceeding_case_id
      expect(proceeding.lead_proceeding).to eq laa_proc.lead_proceeding
      expect(proceeding.ccms_code).to eq laa_proc.proceeding_type.ccms_code
      expect(proceeding.meaning).to eq laa_proc.proceeding_type.meaning
      expect(proceeding.description).to eq laa_proc.proceeding_type.description
      expect(proceeding.substantive_cost_limitation).to eq laa_proc.proceeding_type.default_cost_limitation_substantive
      expect(proceeding.delegated_functions_cost_limitation).to eq laa_proc.proceeding_type.default_cost_limitation_delegated_functions
      expect(proceeding.substantive_scope_limitation_code).to eq(
        laa_proc.proceeding_type.proceeding_type_scope_limitations.where(substantive_default: true).first.scope_limitation.code
      )
      expect(proceeding.substantive_scope_limitation_meaning).to eq(
        laa_proc.proceeding_type.proceeding_type_scope_limitations.where(substantive_default: true).first.scope_limitation.meaning
      )
      expect(proceeding.substantive_scope_limitation_description).to eq(
        laa_proc.proceeding_type.proceeding_type_scope_limitations.where(substantive_default: true).first.scope_limitation.description
      )
      expect(proceeding.delegated_functions_scope_limitation_code).to eq(
        laa_proc.proceeding_type.proceeding_type_scope_limitations.where(delegated_functions_default: true).first.scope_limitation.code
      )
      expect(proceeding.delegated_functions_scope_limitation_meaning).to eq(
        laa_proc.proceeding_type.proceeding_type_scope_limitations.where(delegated_functions_default: true).first.scope_limitation.meaning
      )
      expect(proceeding.delegated_functions_scope_limitation_description).to eq(
        laa_proc.proceeding_type.proceeding_type_scope_limitations.where(delegated_functions_default: true).first.scope_limitation.description
      )
      expect(proceeding.used_delegated_functions_on).to eq laa_proc.used_delegated_functions_on
      expect(proceeding.used_delegated_functions_reported_on).to eq laa_proc.used_delegated_functions_reported_on
      expect(proceeding.name).to eq laa_proc.proceeding_type.name
    end
  end

  describe '.update!' do
    before do
      legal_aid_application.application_proceeding_types.first.update!(used_delegated_functions_on: Time.zone.yesterday)
    end

    it 'updates the corresponding proceeding record' do
      sync_service.update!

      expect(legal_aid_application.proceedings.first.used_delegated_functions_on).to eq Time.zone.yesterday
    end
  end

  describe '.destroy!' do
    before { sync_service.create! }
    it 'deletes the corresponding proceeding record' do
      expect { sync_service.destroy! }.to change { Proceeding.count }.by(-1)
    end
  end
end
