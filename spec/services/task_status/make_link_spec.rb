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

  let(:complete_lead_linked_application) do
    create(:linked_application,
           link_type_code: "LEGAL",
           confirm_link: true,
           associated_application_id: application.id,
           lead_application_id: original_application.id,
           target_application_id: original_application.id)
  end

  let(:original_application) { create(:legal_aid_application) }

  describe "#call" do
    subject(:status) { instance.call }

    before { application.update!(lead_linked_application:) }

    context "with an incomplete applicant" do
      let(:applicant) do
        complete_applicant.update!(addresses: [])
        complete_applicant
      end

      let(:lead_linked_application) { nil }

      it { is_expected.to be_cannot_start }
    end

    context "with all client details completed" do
      let(:applicant) { complete_applicant }
      let(:lead_linked_application) { nil }

      it { is_expected.to be_not_started }
    end

    context "with partially completed link section" do
      let(:applicant) { complete_applicant }

      let(:lead_linked_application) do
        complete_lead_linked_application.update!(link_type_code: nil)
        complete_lead_linked_application
      end

      it { is_expected.to be_in_progress }
    end

    context "with completed link section" do
      let(:applicant) { complete_applicant }
      let(:lead_linked_application) { complete_lead_linked_application }

      before { application.update!(linked_application_completed: true) }

      it { is_expected.to be_completed }
    end
  end
end
