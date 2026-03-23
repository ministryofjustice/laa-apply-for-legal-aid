require "rails_helper"

RSpec.describe TaskStatus::CheckProviderAnswers do
  subject(:instance) { described_class.new(application) }

  let(:application) { create(:application, :with_complete_applicant_and_proceedings, linked_application_completed: true) }

  describe "#call", :vcr do
    subject(:status) { instance.call }

    context "without all previous tasks completed" do
      before do
        application.applicant.update!(national_insurance_number: "JA")
        application.save!
      end

      it { is_expected.to be_not_ready }
    end

    context "with all previous tasks completed but CYA never having been reviewed" do
      let(:applicant) { complete_applicant }

      before do
        application.reviewed.delete(:check_provider_answers)
        application.save!
      end

      it { is_expected.to be_not_started }
    end

    context "with all previous tasks completed and CYA having been marked as in_progress" do
      before do
        application.reviewed[:check_provider_answers] = { status: "in_progress", at: Time.current }
        application.save!
      end

      it { is_expected.to be_in_progress }
    end

    context "with all previous tasks completed and CYA having been marked as completed" do
      before do
        application.reviewed[:check_provider_answers] = { status: "completed", at: Time.current }
        application.save!
      end

      it { is_expected.to be_completed }
    end

    context "with all previous tasks completed but previous forms revisited" do
      before do
        application.reviewed[:check_provider_answers] = nil
        application.save!
      end

      it { is_expected.to be_review }
    end
  end
end
