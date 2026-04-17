require "rails_helper"

RSpec.describe TaskStatus::Partner do
  subject(:instance) { described_class.new(application, status_results) }

  let(:application) { create(:application, :with_applicant, :with_multiple_proceedings_inc_section8) }
  let(:status_results) { {} }
  let(:overriding_dwp_result) { false }
  let(:non_means_tested) { false }

  before do
    allow(application)
      .to receive_messages(overriding_dwp_result?: overriding_dwp_result, non_means_tested?: non_means_tested)
  end

  describe "#call" do
    subject(:status) { instance.call }

    context "when the application is overriding the dwp result" do
      let(:overriding_dwp_result) { true }

      it { is_expected.to be_not_needed }
    end

    context "when the application is non means tested" do
      let(:non_means_tested) { true }

      it { is_expected.to be_not_needed }
    end

    context "when previous tasks are incomplete" do
      let(:status_results) do
        {
          TaskStatus::Applicants => TaskStatus::ValueObject.new.in_progress!,
        }
      end

      it { is_expected.to be_cannot_start }
    end

    context "when previous tasks are complete" do
      let(:status_results) do
        {
          TaskStatus::Applicants => TaskStatus::ValueObject.new.completed!,
          TaskStatus::MakeLink => TaskStatus::ValueObject.new.completed!,
          TaskStatus::ProceedingsTypes => TaskStatus::ValueObject.new.completed!,
        }
      end

      context "and the has_partner question has not been answered" do
        before { application.applicant.update!(has_partner: nil) }

        it { is_expected.to be_not_started }
      end

      context "when the partner question was answered no" do
        before { application.applicant.update!(has_partner: false) }

        it { is_expected.to be_completed }
      end

      context "when the partner question was answered yes" do
        before { application.applicant.update!(has_partner: true) }

        context "and the partner object is not present" do
          before { application.partner&.destroy! }

          it { is_expected.to be_in_progress }
        end

        context "and the partner details are incomplete" do
          before do
            create(:partner, national_insurance_number: nil, has_national_insurance_number: true, legal_aid_application: application)
          end

          it { is_expected.to be_in_progress }
        end

        context "and the partner details are complete" do
          let(:application) { create(:application, :with_applicant_and_partner_with_no_contrary_interest, :with_multiple_proceedings_inc_section8) }

          it { is_expected.to be_completed }
        end
      end
    end
  end
end
