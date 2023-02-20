require "rails_helper"

RSpec.describe SecureApplicationFinder do
  subject { described_class.new(secure_data_id) }

  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:expired_at) { 1.hour.from_now }
  let(:secure_data_id) do
    SecureData.create_and_store!(
      legal_aid_application: { id: legal_aid_application.id },
      expired_at:,
    )
  end

  it "finds the application" do
    expect(subject.legal_aid_application).to eq(legal_aid_application)
  end

  it "has no errors" do
    expect(subject.error).to be_nil
  end

  context "when expired" do
    let(:expired_at) { 1.hour.ago }

    it "does not find the application" do
      expect(subject.legal_aid_application).to eq(legal_aid_application)
    end

    it "has :expired error" do
      expect(subject.error).to eq(:expired)
    end
  end

  context "when the application has a citizen url id" do
    let!(:legal_aid_application) do
      create(
        :legal_aid_application,
        citizen_url_id: "test-citizen-url-id",
        citizen_url_expires_on: 8.days.from_now,
      )
    end

    describe "#legal_aid_application" do
      subject(:found_application) do
        described_class.new(citizen_url_id).legal_aid_application
      end

      context "when a matching application exists" do
        let(:citizen_url_id) { "test-citizen-url-id" }

        it "finds the application" do
          expect(found_application).to eq(legal_aid_application)
        end
      end

      context "when no matching application exists" do
        let(:citizen_url_id) { "non-matching-citizen-url-id" }

        it "raises an error" do
          expect { found_application }
            .to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe "#error" do
      subject(:error) { described_class.new("test-citizen-url-id").error }

      context "when the link has expired" do
        before { travel_to 8.days.from_now }

        it { is_expected.to eq(:expired) }
      end

      context "when the link has not expired" do
        it { is_expected.to be_nil }
      end
    end
  end
end
