require 'rails_helper'

RSpec.describe LegalAidApplicationPolicy do
  subject { LegalAidApplicationPolicy.new(provider, legal_aid_application) }
  let(:legal_aid_application) { create(:legal_aid_application) }

  context 'Another a provider' do
    let(:provider) { create(:provider) }

    it { should_not permit(:show) }
    it { should_not permit(:update) }
  end

  context 'Current provider' do
    let(:provider) do
      legal_aid_application.provider
    end

    it { should permit(:show) }
    it { should permit(:update) }
  end
end
