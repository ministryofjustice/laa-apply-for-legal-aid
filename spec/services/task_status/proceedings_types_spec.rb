require "rails_helper"

RSpec.describe TaskStatus::ProceedingsTypes do
  subject(:instance) { described_class.new(application, status_results) }

  let(:application) { create(:application, applicant:) }
  let(:status_results) { {} }

  let(:applicant) do
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

    context "with partially completed link section" do
      let(:status_results) do
        {
          TaskStatus::Applicants => TaskStatus::ValueObject.new.completed!,
          TaskStatus::MakeLink => TaskStatus::ValueObject.new.in_progress!,
        }
      end

      it { is_expected.to be_cannot_start }
    end

    context "with completed link section" do
      let(:status_results) do
        {
          TaskStatus::Applicants => TaskStatus::ValueObject.new.completed!,
          TaskStatus::MakeLink => TaskStatus::ValueObject.new.completed!,
        }
      end

      it { is_expected.to be_not_started }
    end

    context "with one proceeding added but details not complete", :vcr do
      before do
        create(:proceeding, :da004, legal_aid_application: application)
      end

      it { is_expected.to be_in_progress }
    end

    context "with one proceeding added and details complete", :vcr do
      before do
        create(:proceeding, :da004, legal_aid_application: application, used_delegated_functions: false, accepted_substantive_defaults: true)
      end

      it { is_expected.to be_completed }
    end
  end
end
