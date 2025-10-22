require "rails_helper"

RSpec.describe TaskStatus::MakeLink do
  subject(:instance) { described_class.new(application) }

  let(:application) { create(:application, applicant:) }

  let(:complete_applicant) do
    create(
      :applicant,
      has_national_insurance_number: true,
      national_insurance_number: "JA123456D",
      applied_previously: false,
      previous_reference: nil,
      correspondence_address_choice: "home",
      addresses: [build(:address, location: "home", lookup_used: true)],
      employed: nil,
    )
  end

  describe "#call" do
    subject(:status) { instance.call }

    context "with an incomplete applicant" do
      let(:applicant) do
        complete_applicant.update!(addresses: [])
        complete_applicant
      end

      it { is_expected.to be_cannot_start }
    end

    context "with all client details completed" do
      let(:applicant) { complete_applicant }
      let(:lead_linked_application) { nil }

      it { is_expected.to be_not_started }
    end

    context "with partially completed link section" do
      let(:applicant) { complete_applicant }

      before { application.update!(linked_application_completed: false) }

      it { is_expected.to be_in_progress }
    end

    context "with completed link section" do
      let(:applicant) { complete_applicant }

      before { application.update!(linked_application_completed: true) }

      it { is_expected.to be_completed }
    end
  end
end
