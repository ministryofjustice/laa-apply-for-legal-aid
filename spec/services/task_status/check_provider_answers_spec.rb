require "rails_helper"

RSpec.describe TaskStatus::CheckProviderAnswers do
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

    context "without all previous tasks completed" do
      let(:applicant) do
        complete_applicant.update!(national_insurance_number: "JA")
        complete_applicant
      end

      it { is_expected.to be_not_ready }
    end

    context "with all previous tasks completed but CYA never having been reviewed" do
      let(:applicant) { complete_applicant }

      before do
        application.tracked.delete(:check_provider_answers)
        application.save!
      end

      it { is_expected.to be_not_started }
    end

    context "with all previous tasks completed and CYA having been reviewed" do
      let(:applicant) { complete_applicant }

      before do
        application.tracked[:check_provider_answers] = Time.current
        application.save!
      end

      it { is_expected.to be_completed }
    end

    context "with all previous tasks completed but previous forms revisited" do
      let(:applicant) { complete_applicant }

      before do
        application.tracked[:check_provider_answers] = nil
        application.save!
      end

      it { is_expected.to be_review }
    end
  end
end
