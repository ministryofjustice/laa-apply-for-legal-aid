require "rails_helper"

RSpec.describe TaskStatus::Partner do
  subject(:instance) { described_class.new(application) }

  let(:application) { create(:application, :with_multiple_proceedings_inc_section8) }
  let(:proceeding_validator) { instance_double(TaskStatus::Validators::ProceedingsTypes) }
  let(:proceeding_validator_response) { false }
  let(:non_means?) { false }

  before do
    allow(TaskStatus::Validators::ProceedingsTypes).to receive(:new).with(application).and_return(proceeding_validator)
    allow(proceeding_validator).to receive(:valid?).and_return(proceeding_validator_response)
    allow(application).to receive(:non_means_tested?).and_return(non_means?)
  end

  describe "#call" do
    subject(:status) { instance.call }

    context "when the application is non means tested" do
      let(:non_means?) { true }

      it { is_expected.to be_not_needed }
    end

    context "when the application has no proceedings" do
      it { is_expected.to be_cannot_start }
    end

    context "when the application has proceedings" do
      let(:application) { create(:application, :with_applicant_and_no_partner, :with_proceedings) }

      context "and the has_partner question has not been answered" do
        before { application.applicant.update!(has_partner: nil) }

        let(:proceeding_validator_response) { true }

        it { is_expected.to be_not_started }
      end

      context "when the partner question was answered no" do
        let(:proceeding_validator_response) { true }

        it { is_expected.to be_completed }
      end

      context "when the partner question was answered yes" do
        let(:application) { create(:application, :with_applicant_and_partner, :with_proceedings) }
        let(:proceeding_validator_response) { true }

        context "and the partner details are incomplete" do
          before { application.partner.update!(national_insurance_number: nil) }

          it { is_expected.to be_in_progress }
        end

        context "and the partner details are complete" do
          before { application.applicant.update!(partner_has_contrary_interest: false) }

          it { is_expected.to be_completed }
        end
      end
    end
  end
end
