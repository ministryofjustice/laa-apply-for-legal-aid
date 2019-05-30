require 'rails_helper'

module CCMS # rubocop:disable Metrics/ModuleLength
  RSpec.describe Submission do
    let(:history) { SubmissionHistory.find_by(submission_id: @submission.id) }

    let(:proceeding_type) do
      double ProceedingType,
             ccms_category_law_code: 'MAT',
             ccms_category_law: 'Family',
             ccms_matter: 'Domestic Abuse',
             case_id: 'P_11594790',
             status: 'Draft',
             lead_proceeding_indicator: true,
             ccms_code: 'DA004',
             description: 'to be represented on an application for a non-molestation order. ',
             ccms_matter_code: 'MINJN',
             scope_limitations: [scope_limitation],
             default_level_of_service: 3,
             proportionality_question: 'Yes',
             includes_child: 'No',
             expert_cost_family: 100.0,
             ca_gateway_applies?: false,
             predicted_cost_family: 5300.0,
             schedule_1?: false,
             counsel_fee_family: 100.0,
             generate_warning_letter_sent_block?: true,
             warning_letter_sent?: false,
             generate_police_notified_block?: true,
             police_notified?: true,
             generate_work_in_scheme_1_block?: false,
             work_in_scheme_1?: nil,
             generate_inj_respondent_capacity_block?: true,
             inj_respondent_capacity?: true,
             lead_proceeding_merits?: true,
             meaning: 'Non-molestation order-Domestic Abuse',
             dv_gateway_applies?: false,
             generate_x_border_lar_criteria_block?: false,
             x_border_disputes_lar_criteria?: nil,
             generate_bail_conditions_set_block?: true,
             bail_conditions_set?: false,
             disbursement_cost_family: 100.0,
             generate_child_parties_criteria_block?: false,
             child_parties_criteria?: nil,
             involving_children: 'No',
             dom_violence_waiver_applies: 'Yes',
             lead_proceeding?: true,
             generate_injunction_reason_no_warning_letter_block?: true,
             reason_no_injunction_warning_letter: 'Too dangerous',
             involving_injunction: 'Yes',
             fin_rep_category: 'Domestic Violence',
             matter_type_meaning: 'Domestic Abuse',
             generate_injunction_recent_incident_detail_block?: true,
             injunction_recent_incident_detail: '29/03/2019',
             lar_gateway?: false
    end

    let(:scope_limitation) do
      double 'ScopeLimitation',
             limitation: 'CV118',
             wording: 'Limited to all steps up to and including the hearing on 01/04/2019',
             delegated_functions_apply: true
    end

    before do
      allow_any_instance_of(LegalAidApplication).to receive(:proceeding_types).and_return([proceeding_type])
    end

    before(:all) do
      VCR.configure { |c| c.ignore_hosts 'sitsoa10.laadev.co.uk' }
      @statement_of_case = create :statement_of_case, :with_attached_files
      @legal_aid_application = create :legal_aid_application, :with_applicant_and_address, :with_proceeding_types, statement_of_case: @statement_of_case
      @submission = create :submission, legal_aid_application: @legal_aid_application
      PdfConverter.call(PdfFile.find_or_create_by(original_file_id: @statement_of_case.original_files.first.id).id)
    end

    after(:all) do
      DatabaseCleaner.clean
    end

    describe 'initial state' do
      it 'creates a submission in the initial state' do
        expect(@submission.aasm_state).to eq 'initialised'
      end
    end

    describe 'getting a case id' do
      it 'stores the reference number, updates the state, and writes a history record' do
        @submission.process!
        expect(@submission.case_ccms_reference).not_to be_nil
        expect(@submission.aasm_state).to eq 'case_ref_obtained'
        expect(history.from_state).to eq 'initialised'
        expect(history.to_state).to eq 'case_ref_obtained'
        expect(history.success).to be true
        expect(history.details).to be_nil
      end
    end

    describe 'creating an applicant' do
      it 'stores the transaction_id, updates the state and writes a history record' do
        expect { @submission.process! }.not_to change { @submission.case_ccms_reference }
        expect(@submission.applicant_add_transaction_id).not_to be_nil
        expect(@submission.aasm_state).to eq 'applicant_submitted'
        expect(history.from_state).to eq 'case_ref_obtained'
        expect(history.to_state).to eq 'applicant_submitted'
        expect(history.success).to be true
        expect(history.details).to be_nil
      end
    end

    describe 'polling for applicant creation' do
      it 'stores the applicant_id, updates the state and writes a history record' do
        expect { @submission.process! }.to change { @submission.applicant_poll_count }.by(1) while @submission.applicant_ccms_reference.nil?

        expect(@submission.applicant_ccms_reference).not_to be_nil
        expect(@submission.aasm_state).to eq 'applicant_ref_obtained'
        expect(history.from_state).to eq 'applicant_submitted'
        expect(history.to_state).to eq 'applicant_ref_obtained'
        expect(history.success).to be true
        expect(history.details).to be_nil
      end
    end

    describe 'creating a case' do
      it 'stores the transaction_id, updates the state and writes a history record' do
        @submission.process!
        expect(@submission.aasm_state).to eq 'case_submitted'
        expect(history.from_state).to eq 'applicant_ref_obtained'
        expect(history.to_state).to eq 'case_submitted'
        expect(history.success).to be true
        expect(history.details).to be_nil
      end
    end

    describe 'polling for case creation' do
      it 'updates the state and writes a history record' do
        while @submission.aasm_state != 'case_created'
          sleep(10)
          expect { @submission.process! }.to change { @submission.case_poll_count }.by(1)
        end

        expect(@submission.applicant_ccms_reference).not_to be_nil
        expect(@submission.aasm_state).to eq 'case_created'
        expect(history.from_state).to eq 'case_submitted'
        expect(history.to_state).to eq 'case_created'
        expect(history.success).to be true
        expect(history.details).to be_nil
      end
    end

    describe 'getting document ids' do
      # context 'there are no documents' do
      #   it 'updates the state and writes a history record' do
      #     @submission.process!
      #     expect(@submission.documents).to be_empty
      #     expect(@submission.aasm_state).to eq 'completed'
      #     expect(history.from_state).to eq 'case_created'
      #     expect(history.to_state).to eq 'completed'
      #     expect(history.success).to be true
      #     expect(history.details).to be_nil
      #   end
      # end

      context 'there are documents' do
        it 'populates the document list, stores document_ids, updates the state and writes a history record' do
          @submission.process!
          expect(@submission.documents).to_not be_empty
          expect(@submission.documents.values[0]).to eq :id_obtained
          expect(@submission.aasm_state).to eq 'document_ids_obtained'
          expect(history.from_state).to eq 'case_created'
          expect(history.to_state).to eq 'document_ids_obtained'
          expect(history.success).to be true
          expect(history.details).to be_nil
        end
      end

      describe 'uploading documents' do
        it 'updates the state and writes a history record' do
          @submission.process!
          expect(@submission.documents.values[0]).to eq :uploaded
          expect(@submission.aasm_state).to eq 'completed'
          expect(history.from_state).to eq 'document_ids_obtained'
          expect(history.to_state).to eq 'completed'
          expect(history.success).to be true
          expect(history.details).to be_nil
        end
      end
    end
  end
end
