require "rails_helper"

RSpec.describe Citizen::AccessToken do
  describe ".find_by_token" do
    subject(:find_by_token) { described_class.find_by_token(token) }

    let(:access_token) { create(:citizen_access_token, token:) }
    let(:token) { "find-this-token" }

    it "queries by deteministically encrypted token" do
      expect(access_token).to eq(find_by_token)
    end
  end

  describe ".generate_for" do
    subject(:generate_token) { described_class.generate_for(legal_aid_application:) }

    let(:legal_aid_application) { build(:legal_aid_application) }

    before do
      travel_to Date.new(2024, 1, 1)
      allow(SecureRandom).to receive(:uuid).and_return("test-uuid")
    end

    it "encrypts a unique access token that expires in 8 days" do
      expect(generate_token).to have_attributes(
        token: "test-uuid",
        expires_on: Date.new(2024, 1, 9),
        legal_aid_application:,
      )
    end
  end

  describe "#validate" do
    subject(:access_token) { build(:citizen_access_token, expires_on:) }

    context "when expires_on is in the past" do
      let(:expires_on) { 1.day.ago }

      it { is_expected.to be_invalid }
    end

    context "when expires_on is today" do
      let(:expires_on) { Date.current }

      it { is_expected.to be_invalid }
    end

    context "when expires_on is in the future" do
      let(:expires_on) { 1.day.from_now }

      it { is_expected.to be_valid }
    end
  end
end
