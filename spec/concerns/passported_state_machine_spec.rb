require 'rails_helper'

RSpec.describe PassportedStateMachine do
  describe 'provider_enter_means!' do
    it 'sets the ccms_reason to nil' do
      legal_aid_application = create :legal_aid_application, :use_ccms_employed
      legal_aid_application.provider_enter_means!
      expect(legal_aid_application.ccms_reason).to be_nil
    end
  end
end
