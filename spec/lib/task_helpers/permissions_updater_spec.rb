require 'rails_helper'
require Rails.root.join('lib/tasks/helpers/permissions_updater')

RSpec.describe PermissionsUpdater do
  let!(:firm_both) { create :firm, :with_passported_and_non_passported_permissions }
  let!(:firm_non_passported) { create :firm, :with_non_passported_permissions }
  let!(:firm_passported) { create :firm, :with_passported_permissions }
  let!(:firm_none) { create :firm, :with_no_permissions }

  it 'adds non_passported permissions' do
    PermissionsUpdater.new.run
    expect(firm_both.reload.permissions.map(&:role)).to match_array(['application.passported.*', 'application.non_passported.*'])
    expect(firm_non_passported.reload.permissions.map(&:role)).to match_array(['application.passported.*', 'application.non_passported.*'])
    expect(firm_passported.reload.permissions.map(&:role)).to match_array(['application.passported.*', 'application.non_passported.*'])
    expect(firm_none.reload.permissions.map(&:role)).to match_array(['application.passported.*', 'application.non_passported.*'])
  end
end
