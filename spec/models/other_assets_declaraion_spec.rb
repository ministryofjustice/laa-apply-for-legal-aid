require 'rails_helper'

RSpec.describe OtherAssetsDeclaration do
  describe 'unique index on legal_aid_application_id' do
    it 'throws an exception if you attempt to create a second record for an application' do
      application = create :legal_aid_application
      application.create_other_assets_declaration!
      expect {
        OtherAssetsDeclaration.create!(legal_aid_application_id: application.id)
      }.to raise_error ActiveRecord::RecordNotUnique
    end
  end
end
