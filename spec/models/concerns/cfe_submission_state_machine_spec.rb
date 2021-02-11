require 'rails_helper'

module CFE
  RSpec.describe CFESubmissionStateMachine do
    context 'initial state' do
      it 'creates an application in initialised state' do
        submission = create :cfe_submission
        expect(submission.initialised?).to be true
      end
    end

    context 'asssessment_created! event' do
      it 'transitions from initialised to assessment_created' do
        submission = create :cfe_submission
        submission.assessment_created!
        expect(submission.assessment_created?).to be true
      end
    end

    context 'results_obtained! event' do
      context 'passported application' do
        let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }
        let(:submission) { create :cfe_submission, legal_aid_application: legal_aid_application, aasm_state: 'explicit_remarks_created' }

        it 'transitions from explicit remarks created created to results obtained' do
          expect { submission.results_obtained! }.not_to raise_error
          expect(submission.results_obtained?).to be true
        end
      end

      context 'non_passported_application' do
        let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result }

        context 'from properties_created state' do
          let(:submission) { create :cfe_submission, legal_aid_application: legal_aid_application, aasm_state: 'properties_created' }

          it 'raises' do
            expect { submission.results_obtained! }.to raise_error AASM::InvalidTransition, /Event 'results_obtained' cannot transition from 'properties_created'/
          end
        end
      end
    end

    context 'dependants_created! event' do
      let(:submission) { create :cfe_submission, legal_aid_application: legal_aid_application, aasm_state: 'explicit_remarks_created' }

      context 'passported' do
        let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }
        it 'raises' do
          expect { submission.dependants_created! }.to raise_error AASM::InvalidTransition, /Event 'dependants_created' cannot transition from 'explicit_remarks_created'/
        end
      end

      context 'non_passported' do
        let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result }

        it 'transitions from explicit_remarks_created to dependants_created' do
          expect { submission.dependants_created! }.not_to raise_error
          expect(submission.dependants_created?).to be true
        end
      end
    end

    context 'outgoings_created! event' do
      let(:submission) { create :cfe_submission, legal_aid_application: legal_aid_application, aasm_state: 'dependants_created' }

      context 'passported' do
        let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }
        it 'raises' do
          expect { submission.outgoings_created! }.to raise_error AASM::InvalidTransition, /Event 'outgoings_created' cannot transition from 'dependants_created'/
        end
      end

      context 'non_passported' do
        let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result }

        it 'transitions from properties created to dependants_created' do
          expect { submission.outgoings_created! }.not_to raise_error
          expect(submission.outgoings_created?).to be true
        end
      end
    end

    context 'state_benefits_created! event' do
      let(:submission) { create :cfe_submission, legal_aid_application: legal_aid_application, aasm_state: 'outgoings_created' }

      context 'passported' do
        let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }
        it 'raises' do
          expect { submission.state_benefits_created! }.to raise_error AASM::InvalidTransition, /Event 'state_benefits_created' cannot transition from 'outgoings_created'/
        end
      end

      context 'non_passported' do
        let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result }

        it 'transitions from properties created to dependants_created' do
          expect { submission.state_benefits_created! }.not_to raise_error
          expect(submission.state_benefits_created?).to be true
        end
      end
    end

    context 'other_income_created! event' do
      let(:submission) { create :cfe_submission, legal_aid_application: legal_aid_application, aasm_state: 'state_benefits_created' }

      context 'passported' do
        let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }
        it 'raises' do
          expect { submission.other_income_created! }.to raise_error AASM::InvalidTransition, /Event 'other_income_created' cannot transition from 'state_benefits_created'/
        end
      end

      context 'non_passported' do
        let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result }

        it 'transitions from state_benefits_created to other_income_created' do
          expect { submission.other_income_created! }.not_to raise_error
          expect(submission.other_income_created?).to be true
        end
      end
    end

    context 'explicit_remarks_created! event' do
      let(:submission) { create :cfe_submission, legal_aid_application: legal_aid_application, aasm_state: 'properties_created' }

      context 'passported' do
        let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }
        it 'transitions from state_benefits_created to other_income_created' do
          expect { submission.explicit_remarks_created! }.not_to raise_error
          expect(submission.explicit_remarks_created?).to be true
        end
      end

      context 'non_passported' do
        let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result }

        it 'transitions from state_benefits_created to other_income_created' do
          expect { submission.explicit_remarks_created! }.not_to raise_error
          expect(submission.explicit_remarks_created?).to be true
        end
      end
    end

    context 'fail! event' do
      let(:states) { Submission.aasm.states.map(&:name) - %i[failed results_obtained] }
      it 'transitions to failed from all states except failed and results obtained' do
        states.each do |state|
          submission = create :cfe_submission, aasm_state: state
          expect { submission.fail! }.not_to raise_error
          expect(submission.failed?).to be true
        end
      end
    end
  end
end
