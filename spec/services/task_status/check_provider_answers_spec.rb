require "rails_helper"

RSpec.describe TaskStatus::CheckProviderAnswers do
  subject(:instance) { described_class.new(application, status_results) }

  let(:application) { create(:application, :with_complete_applicant_and_proceedings, linked_application_completed: true) }
  let(:status_results) { {} }

  describe "#call", :vcr do
    subject(:status) { instance.call }

    context "without all previous tasks completed" do
      let(:status_results) { { TaskStatus::Applicants => TaskStatus::ValueObject.new.in_progress! } }

      it { is_expected.to be_not_ready }
    end

    context "without all expected previous tasks present" do
      let(:status_results) do
        {
          TaskStatus::Applicants => TaskStatus::ValueObject.new.completed!,
        }
      end

      it { is_expected.to be_not_ready }
    end

    context "with all previous tasks completed" do
      let(:status_results) do
        {
          TaskStatus::Applicants => TaskStatus::ValueObject.new.completed!,
          TaskStatus::MakeLink => TaskStatus::ValueObject.new.completed!,
          TaskStatus::ProceedingsTypes => TaskStatus::ValueObject.new.completed!,
        }
      end

      context "and CYA never having been reviewed" do
        before do
          application.reviewed.delete(:check_provider_answers)
          application.save!
        end

        it { is_expected.to be_not_started }
      end

      context "and CYA having been marked as in_progress" do
        before do
          application.reviewed[:check_provider_answers] = { status: "in_progress", at: Time.current }
          application.save!
        end

        it { is_expected.to be_in_progress }
      end

      context "and CYA having been marked as completed" do
        before do
          application.reviewed[:check_provider_answers] = { status: "completed", at: Time.current }
          application.save!
        end

        it { is_expected.to be_completed }
      end

      context "and previous forms revisited" do
        before do
          application.reviewed[:check_provider_answers] = nil
          application.save!
        end

        it { is_expected.to be_review }
      end
    end
  end
end
