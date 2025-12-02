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

    shared_examples "invalid schedule" do |attribute, message|
      it "is invalid with error on #{attribute}" do
        instance = described_class.new(schedule)

        expect(instance.valid?).to be false
        expect(instance.errors).to include(an_object_having_attributes(attribute: attribute, message: message))
      end

      it "logs error on #{attribute}" do
        allow(Rails.logger).to receive(:info)
        call
        expect(Rails.logger).to have_received(:info).with(/#{message}/)
      end

      it "captures sentry error on #{attribute}" do
        allow(AlertManager).to receive(:capture_message)
        call
        expect(AlertManager).to have_received(:capture_message).with(/Schedule is invalid \(id: .*\) - #{message}/)
      end
    end

    context "with a valid schedule" do
      it { is_expected.to be_truthy }

      it "does not log error" do
        allow(Rails.logger).to receive(:info)
        call
        expect(Rails.logger).not_to have_received(:info)
      end

      it "does not capture error on sentry" do
        allow(AlertManager).to receive(:capture_message)
        call
        expect(AlertManager).not_to have_received(:capture_message)
      end
    end

    context "with a license count of zero" do
      let(:license_indicator) { 0 }

      it_behaves_like "invalid schedule", :license_indicator, "No license indicator"
    end

    context "without a valid devolved power status" do
      let(:devolved_power_status) { nil }

      it_behaves_like "invalid schedule", :devolved_power_status, "Devolved power status incorrect"
    end

    context "with a start date in the future" do
      let(:start_date) { Date.current + 10.days }

      it_behaves_like "invalid schedule", :start_date, "Schedule start date is in the future"
    end

    context "with an end date in the past" do
      let(:end_date) { Date.current - 10.days }

      it_behaves_like "invalid schedule", :end_date, /Schedule end date is in the past: .*/
    end

    context "when schedule is cancelled" do
      let(:cancelled) { true }

      it_behaves_like "invalid schedule", :cancelled, "Schedule is cancelled"
    end

    context "when authorisation_status is not valid" do
      let(:authorisation_status) { nil }

      it_behaves_like "invalid schedule", :authorisation_status, "Authorisation status is not approved"
    end

    context "when status is not open" do
      let(:status) { nil }

      it_behaves_like "invalid schedule", :status, "Schedule status is not open"
    end
  end
end
