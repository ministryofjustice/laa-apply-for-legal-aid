require 'rails_helper'

RSpec.describe IdPSettingsAdapter do
  describe 'IdPSettingsAdapter.mock_saml?' do
    let(:setting) { 'true' }
    before do
      allow(Rails.configuration.x.laa_portal).to receive(:mock_saml).and_return(setting)
    end

    it 'returns true' do
      expect(IdPSettingsAdapter.mock_saml?).to eq(true)
    end

    context 'when set "false"' do
      let(:setting) { 'false' }

      it 'returns false' do
        expect(IdPSettingsAdapter.mock_saml?).to eq(false)
      end
    end
  end

  describe 'IdPSettingsAdapter.settings' do
    context 'UAT settings' do
      it 'returns a hash of settings' do
        allow(IdPSettingsAdapter).to receive(:mock_saml?).and_return(true)
        expect(IdPSettingsAdapter.settings(1)).to have_key(:private_key)
        expect(IdPSettingsAdapter.settings(1)).to have_value(nil)
      end
    end

    context 'Non UAT settings' do
      it 'returns a hash of settings' do
        allow(IdPSettingsAdapter).to receive(:mock_saml?).and_return(false)
        expect(IdPSettingsAdapter.settings(1)).to have_key(:issuer)
        expect(IdPSettingsAdapter.settings(1)).to have_value('apply')
      end
    end
  end
end
