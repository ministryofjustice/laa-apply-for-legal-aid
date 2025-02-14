require "rails_helper"

RSpec.describe SecureApplicationFinder do
  let(:legal_aid_application) { build(:legal_aid_application) }
  let(:citizen_access_token) do
    create(
      :citizen_access_token,
      legal_aid_application:,
      expires_on: Time.zone.today + 2.years,
    )
  end

  before { travel_to today }

  describe "#legal_aid_application" do
    subject(:found_application) do
      described_class.new(search_token).legal_aid_application
    end

    context "when the access token is valid" do
      let(:search_token) { citizen_access_token.token }
      let(:today) { citizen_access_token.expires_on.days_ago(1) }

      it "finds the application" do
        expect(found_application).to eq(legal_aid_application)
      end
    end

    context "when the access token has expired" do
      let(:search_token) { citizen_access_token.token }
      let(:today) { citizen_access_token.expires_on }

      it "finds the application" do
        expect(found_application).to eq(legal_aid_application)
      end
    end

    context "when the access token does not exist" do
      let(:search_token) { SecureRandom.uuid }
      let(:today) { citizen_access_token.expires_on.days_ago(1) }

      it "raises an `ActiveRecord::RecordNotFound` error" do
        expect { found_application }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#error" do
    subject(:error) { described_class.new(search_token).error }

    context "when the access token is valid" do
      let(:search_token) { citizen_access_token.token }
      let(:today) { citizen_access_token.expires_on.days_ago(1) }

      it { is_expected.to be_nil }
    end

    context "when the access token has expired" do
      let(:search_token) { citizen_access_token.token }
      let(:today) { citizen_access_token.expires_on }

      it { is_expected.to eq(:expired) }
    end

    context "when the access token does not exist" do
      let(:search_token) { SecureRandom.uuid }
      let(:today) { citizen_access_token.expires_on.days_ago(1) }

      it "raises an `ActiveRecord::RecordNotFound` error" do
        expect { error }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
