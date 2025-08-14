require "rails_helper"

RSpec.describe PDA::ScheduleValidator do
  describe ".call" do
    subject(:call) { described_class.call(schedule) }

    let(:schedule) { create(:schedule, license_indicator:, devolved_power_status:, start_date:, end_date:, cancelled:, authorisation_status:, status:) }
    let(:license_indicator) { 1 }
    let(:devolved_power_status) { "Yes - Excluding JR Proceedings" }
    let(:start_date) { Date.current - 10.days }
    let(:end_date) { Date.current + 10.days }
    let(:cancelled) { false }
    let(:authorisation_status) { "APPROVED" }
    let(:status) { "Open" }

    context "with a valid schedule" do
      it { is_expected.to be_truthy }
    end

    context "with a license count of zero" do
      let(:license_indicator) { 0 }

      it { is_expected.not_to be_truthy }
    end

    context "without a valid devolved power status" do
      let(:devolved_power_status) { nil }

      it { is_expected.not_to be_truthy }
    end

    context "with a start date in the future" do
      let(:start_date) { Date.current + 10.days }

      it { is_expected.not_to be_truthy }
    end

    context "with an end date in the past" do
      let(:end_date) { Date.current - 10.days }

      it { is_expected.not_to be_truthy }
    end

    context "when schedule is cancelled" do
      let(:cancelled) { true }

      it { is_expected.not_to be_truthy }
    end

    context "when authorisation_status is not valid" do
      let(:authorisation_status) { nil }

      it { is_expected.not_to be_truthy }
    end

    context "when status is not open" do
      let(:status) { nil }

      it { is_expected.not_to be_truthy }
    end
  end
end
