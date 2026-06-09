require "rails_helper"

RSpec.describe Datastore::TokenResponse do
  subject(:instance) { described_class.new(raw_response) }

  let(:raw_response) do
    {
      "access_token" => "fake_access_token",
      "refresh_token" => "fake_refresh_token",
      "expires_in" => 3600,
      "id_token" => "fake_id_token",
      "scope" => "fake_scope1 fake_scope2",
    }
  end

  it { is_expected.to have_attributes(raw_response: raw_response) }

  describe "#access_token" do
    it "returns access token from raw response" do
      expect(instance.access_token).to eq("fake_access_token")
    end
  end

  describe "#refresh_token" do
    it "returns refresh token from raw response" do
      expect(instance.refresh_token).to eq("fake_refresh_token")
    end
  end

  describe "#expires_in" do
    it "returns expires_in from raw response" do
      expect(instance.expires_in).to eq(3600)
    end
  end

  describe "#id_token" do
    it "returns id token from raw response" do
      expect(instance.id_token).to eq("fake_id_token")
    end
  end

  describe "#scope" do
    it "returns scope from raw response" do
      expect(instance.scope).to eq("fake_scope1 fake_scope2")
    end
  end
end
