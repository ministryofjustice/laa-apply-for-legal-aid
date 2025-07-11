require "rails_helper"

RSpec.describe TaskStatus::Applicants do
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

    let(:application) { create(:application, applicant:) }

    context "without an applicant" do
      let(:applicant) { nil }

      it { is_expected.to be_not_started }
    end

    context "with all client details completed" do
      let(:applicant) { complete_applicant }

      it { is_expected.to be_completed }
    end

    context "with partially completed applicant" do
      let(:applicant) do
        complete_applicant.update!(national_insurance_number: "JA")
        complete_applicant
      end

      it { is_expected.to be_in_progress }
    end
  end
end
