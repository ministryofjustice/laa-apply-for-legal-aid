require 'rails_helper'

RSpec.describe RemoveScopeLimitationService do
  let(:legal_aid_application) { create :legal_aid_application }

  before do
    ServiceLevel.populate
    ProceedingType.populate
    ScopeLimitation.populate
    ProceedingTypeScopeLimitation.populate
    pt = ProceedingType.first
    legal_aid_application.proceeding_types << pt
    default_substantive_scope = pt.default_substantive_scope_limitation
    default_df_scope = pt.default_delegated_functions_scope_limitation
    application_proceeding_type = legal_aid_application.proceeding_types.first
    pt.assigned_scope_limitations << AssignedScopeLimitation.new(scope_limitation: default_substantive_scope)
    pt.assigned_scope_limitations << AssignedScopeLimitation.new(scope_limitation: default_df_scope)
    pt.save!
  end

  it 'tests something' do
    pp application_proceeding_type
    # binding.pry
  end
end
