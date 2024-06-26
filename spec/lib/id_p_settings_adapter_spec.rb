require "rails_helper"

RSpec.describe IdPSettingsAdapter do
  describe "IdPSettingsAdapter.mock_saml?" do
    let(:setting) { "true" }

    before do
      allow(Rails.configuration.x.laa_portal).to receive(:mock_saml).and_return(setting)
    end

    it "returns true" do
      expect(described_class.mock_saml?).to be(true)
    end

    context 'when set "false"' do
      let(:setting) { "false" }

      it "returns false" do
        expect(described_class.mock_saml?).to be(false)
      end
    end
  end

  describe "IdPSettingsAdapter.settings" do
    context "with UAT settings" do
      it "returns a hash of settings" do
        allow(described_class).to receive(:mock_saml?).and_return(true)
        expect(described_class.settings(1)).to have_key(:private_key)
        expect(described_class.settings(1)).to have_value(nil)
      end
    end

    context "with non UAT settings" do
      it "returns a hash of settings" do
        allow(described_class).to receive(:mock_saml?).and_return(false)
        expect(described_class.settings(1)).to have_key(:issuer)
        expect(described_class.settings(1)).to have_value("apply")
      end
    end
  end
end
