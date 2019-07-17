require 'rails_helper'

RSpec.describe ApplicationProceedingType, type: :model do
  let!(:provider) { create(:provider) }
  let(:application_proceeding_type) { ApplicationProceedingType.create(legal_aid_application: legal_aid_application, proceeding_type: proceeding_type) }
  let(:legal_aid_application) { LegalAidApplication.create(provider: provider) }
  let(:proceeding_type) { create :proceeding_type, :with_real_data }

  it 'should belong to an proceeding_type and legal_aid_application' do
    expect(application_proceeding_type.legal_aid_application_id).not_to be_nil
    expect(application_proceeding_type.legal_aid_application_id).to eq(legal_aid_application.id)
    expect(application_proceeding_type.proceeding_type.id).not_to be_nil
    expect(application_proceeding_type.proceeding_type_id).to eq(proceeding_type.id)
  end

  describe 'should have associations with legal_aid_application and proceeding_type' do
    it { should belong_to(:legal_aid_application) }
    it { should belong_to(:proceeding_type) }
  end
end
