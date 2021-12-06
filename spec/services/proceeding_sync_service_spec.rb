require 'rails_helper'

RSpec.describe ProceedingSyncService do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:proceeding_type) { create :proceeding_type, :with_scope_limitations }
  let(:sync_service) { described_class.new(legal_aid_application.application_proceeding_types.first) }

  before do
    ApplicationProceedingType.set_callback(:update, :after, :update_proceeding)

    legal_aid_application.proceeding_types << proceeding_type
    Proceeding.create_from_proceeding_type(legal_aid_application, proceeding_type)
  end

  after do
    ApplicationProceedingType.skip_callback(:update, :after, :update_proceeding, raise: false)
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
end
