require "rails_helper"

RSpec.describe Announcement do
  subject(:announcement) { described_class.build(params) }

  let(:display_type) { :gov_uk }
  let(:gov_uk_header_bar) { "Important" }
  let(:heading) { "Database update" }
  let(:link_display) { "Click for details" }
  let(:link_url) { "https://example.com" }
  let(:body) { "System will be offline for 30 minutes" }
  let(:start_at) { Time.zone.local(2025, 11, 1, 9, 0) }
  let(:end_at) { Time.zone.local(2025, 11, 10, 17, 0) }

  describe "validations" do
    let(:params) do
      {
        display_type:,
        gov_uk_header_bar:,
        heading:,
        link_display:,
        link_url:,
        body:,
        start_at:,
        end_at:,
      }
    end

    context "when all values are present" do
      it { is_expected.to be_valid }
    end

    context "when the message body is left out" do
      let(:body) { nil }

      it { is_expected.to be_valid }
    end

    context "when the url is left out completely" do
      let(:link_display) { nil }
      let(:link_url) { nil }

      it { is_expected.to be_valid }
    end

    context "when only the link_url is completed" do
      let(:link_display) { nil }

      it { is_expected.to be_invalid }
    end

    context "when only the link_display is completed" do
      let(:link_url) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the display_type is govuk" do
      context "and the heading is present" do
        it { is_expected.to be_valid }
      end

      context "and the heading is missing" do
        let(:heading) { nil }

        it { is_expected.to be_invalid }
      end
    end

    context "when the display_type is moj" do
      let(:display_type) { :moj }

      context "and the heading and body are present" do
        it { is_expected.to be_valid }
      end

      context "and the heading is missing" do
        let(:heading) { nil }

        it { is_expected.to be_valid }
      end

      context "and the body is missing" do
        let(:body) { nil }

        it { is_expected.to be_invalid }
      end
    end
  end

  describe ".active?" do
    let(:announcement) { described_class.create!(display_type: :gov_uk, heading: "one", start_at:, end_at:) }

    context "when the current time is between the start and end date" do
      let(:start_at) { 5.minutes.ago }
      let(:end_at) { 5.minutes.from_now }

      it "returns true" do
        expect(announcement.active?).to be true
      end
    end

    context "when the current time is not between the start and end date" do
      let(:start_at) { 10.minutes.ago }
      let(:end_at) { 5.minutes.ago }

      it "returns false" do
        expect(announcement.active?).to be false
      end
    end
  end

  describe "scopes" do
    before do
      described_class.create!(display_type: :gov_uk, heading: "one", start_at: Time.zone.local(2025, 11, 1, 9, 0), end_at: Time.zone.local(2025, 11, 10, 17, 0))
      described_class.create!(display_type: :gov_uk, heading: "two", start_at: Time.zone.local(2025, 11, 11, 9, 0), end_at: Time.zone.local(2025, 11, 21, 17, 0))
      described_class.create!(display_type: :gov_uk, heading: "three", start_at: Time.zone.local(2025, 11, 20, 9, 0), end_at: Time.zone.local(2025, 11, 30, 17, 0))
    end

    describe ".active" do
      it "when the date is not covered" do
        travel_to Time.zone.local(2025, 10, 1, 13, 24, 44) do
          expect(described_class.active.count).to eq 0
        end
      end

      it "when the date is covered" do
        travel_to Time.zone.local(2025, 11, 2, 13, 24, 44) do
          expect(described_class.active.count).to eq 1
        end
      end

      it "when the date has multiple" do
        travel_to Time.zone.local(2025, 11, 20, 13, 24, 44) do
          expect(described_class.active.count).to eq 2
        end
      end
    end
  end
end
