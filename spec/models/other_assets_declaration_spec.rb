require "rails_helper"

RSpec.describe OtherAssetsDeclaration do
  describe "unique index on legal_aid_application_id" do
    it "throws an exception if you attempt to create a second record for an application" do
      application = create(:legal_aid_application)
      application.create_other_assets_declaration!
      expect {
        described_class.create!(legal_aid_application_id: application.id)
      }.to raise_error ActiveRecord::RecordNotUnique
    end
  end

  describe "#positive" do
    subject(:other_asset_declaration) { create(:other_assets_declaration) }

    context "with no savings" do
      it "is negative" do
        expect(other_asset_declaration.positive?).to be(false)
      end
    end

    context "with some savings" do
      before { other_asset_declaration.update!(land_value: rand(1...1_000_000.0).round(2)) }

      it "is positive" do
        expect(other_asset_declaration.positive?).to be(true)
      end
    end
  end
end
