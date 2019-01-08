require 'rails_helper'

RSpec.describe IdPSettingsAdapter do
  describe 'IdPSettingsAdapter.mock_saml?' do
    it 'return false' do
      mock_saml_setting = Rails.configuration.x.laa_portal[:mock_saml]
      expected = mock_saml_setting.present? ? ActiveRecord::Type::Boolean.new.cast(mock_saml_setting) : false
      expect(IdPSettingsAdapter.mock_saml?).to eq expected
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
