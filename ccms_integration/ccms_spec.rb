require 'rails_helper'

#
# NOTE: All of the specs here are protected with if RSpec.configuration.run_ccms_integrations_specs?
#       which means they will only run if the RUN_CCMS_INTEGRATION_SPECS environment variable is set to 1
#

module CCMS
  RSpec.describe Submission do
    let(:proceeding_type_1) do
      double ProceedingType,
             action_damages_against_police: false,
             appeal_in_supreme_court: false,
             available_amendment_only: 'No',
             bail_conditions_set?: false,
             ca_gateway_applies?: false,
             case_id: 'P_11594790',
             ccms_category_law: 'Family',
             ccms_category_law_code: 'MAT',
             ccms_code: 'DA004',
             ccms_matter: 'Domestic Abuse',
             ccms_matter_code: 'MINJN',
             child_abduction: 'No',
             child_parties_criteria?: false,
             client_bringing_or_defending: false,
             client_defendant_3rd_pty: false,
             client_inv_type_appellant: false,
             client_inv_type_bring_3rd_pty: false,
             client_inv_type_bringing_counter: false,
             client_inv_type_bringing_procs: true,
             client_inv_type_child: false,
             client_inv_type_def_counter: false,
             client_inv_type_defend_procs: false,
             client_inv_type_interpleader: false,
             client_inv_type_intervenor: false,
             client_inv_type_joined_party: false,
             client_inv_type_other: false,
             client_inv_type_personal_rep: false,
             client_involvement_type: 'A',
             client_involvement: 'Applicant/Claimant/Petitioner',
             counsel_fee_family: 100.0,
             damages_against_police: 'No',
             default_level_of_service: 3,
             delegated_functions_date: Date.new(2019, 4, 1),
             description: 'to be represented on an application for a non-molestation order.',
             disbursement_cost_family: 100.0,
             dom_violence_waiver_applies: 'Yes',
             dv_gateway_applies?: false,
             expert_cost_family: 100.0,
             family_prospects_of_success: '50% or Better',
             fam_prosp_50_or_better: true,
             fam_prosp_border_uncert_poor: false,
             fam_prosp_borderline_uncert: false,
             fam_prosp_good: false,
             fam_prosp_marginal: false,
             fam_prosp_poor: false,
             fam_prosp_uncertain: false,
             fam_prosp_very_good: false,
             fam_prosp_very_poor: false,
             fin_rep_category: 'Domestic Violence',
             generate_bail_conditions_set_block?: true,
             generate_child_parties_criteria_block?: false,
             generate_inj_respondent_capacity_block?: true,
             generate_injunction_reason_no_warning_letter_block?: true,
             generate_injunction_recent_incident_detail_block?: true,
             generate_police_notified_block?: true,
             generate_warning_letter_sent_block?: true,
             generate_work_in_scheme_1_block?: false,
             generate_x_border_lar_criteria_block?: false,
             high_cost_case_routing: 'VHCC',
             immigration_related: false,
             immigration_question_applies: 'No',
             includes_child: 'No',
             inj_respondent_capacity?: true,
             injunction_recent_incident_detail: '29/03/2019',
             involving_children: 'No',
             involving_injunction: 'Yes',
             judicial_review: false,
             lar_gateway?: false,
             lead_proceeding?: true,
             lead_proceeding_indicator: true,
             lead_proceeding_merits?: true,
             level_of_service: 3,
             level_of_service_fhh: false,
             level_of_service_fr: true,
             level_of_serv_ih: false,
             level_of_serv_inquest: false,
             limitation_desc: 'MULTIPLE',
             matrimonial_proceeding: 'No',
             matter_type_child_abduction: 'No',
             matter_type_meaning: 'Domestic Abuse',
             matter_type_private_family: 'Yes',
             matter_type_public_family: 'No',
             matter_type_stand_alone: 'No',
             meaning: 'Non-molestation order-Domestic Abuse',
             new_or_existing: 'NEW',
             new_or_existing_merits: 'NEW',
             non_quantifiable_remedy: false,
             outcome_no_outcome: true,
             overwhelming_importance: false,
             police_notified?: true,
             predicted_cost_family: 5300.0,
             private_funding_applicable: false,
             private_funding_considered: 'No',
             proc_care_superv_or_related: 'No',
             proc_involving_fin_and_prop: 'No',
             proc_is_merits_tested: 'Yes',
             proc_is_sca_or_related: 'No',
             proc_is_sca_appeal: false,
             proc_outcome_recorded: false,
             proc_possession: 'No',
             proc_register_foreign_order: 'No',
             proc_related_sca_or_related: false,
             proc_subject_to_dp_check: 'Yes',
             proc_subject_to_mediation: 'Yes',
             proc_upper_tribunal: 'No',
             proceeding_application_type: 'Both',
             proceeding_case_owner_scu: false,
             proceeding_level_of_service: 'Full Representation',
             proceeding_limitation_meaning: 'MULTIPLE',
             proceeding_new_or_existing: 'NEW',
             proceeding_stand_alone: 'No',
             proceeding_type: 'proc error',
             profit_cost_family: 5_000.0,
             proportionality_question: 'Yes',
             prospects_of_success: 'FA',
             reason_no_injunction_warning_letter: 'Too dangerous',
             related_proceeding: false,
             related_sca_or_related: false,
             requested_scope: 'MULTIPLE',
             routing_for_proceeding: 'Standard Family Merits',
             sca_appeal_final_order: false,
             schedule_1?: false,
             scope_limit_is_default: false,
             scope_limitations: [scope_limitation_1, scope_limitation_2],
             significant_wider_public_interest: false,
             smod_applicable: 'No',
             status: 'draft',
             warning_letter_sent?: false,
             work_in_scheme_1?: nil,
             x_border_disputes_lar_criteria?: false
    end

    let(:proceeding_type_2) do
      double ProceedingType,
             action_damages_against_police: false,
             appeal_in_supreme_court: false,
             available_amendment_only: 'No',
             bail_conditions_set?: false,
             ca_gateway_applies?: true,
             case_id: 'P_11594793',
             ccms_category_law: 'Family',
             ccms_category_law_code: 'MAT',
             ccms_code: 'SE014',
             ccms_matter: 'Children-Section 8 orders',
             ccms_matter_code: 'KSEC8',
             child_abduction: 'No',
             child_parties_criteria?: false,
             client_bringing_or_defending: false,
             client_defendant_3rd_pty: false,
             client_inv_type_appellant: false,
             client_inv_type_bring_3rd_pty: false,
             client_inv_type_bringing_counter: false,
             client_inv_type_bringing_procs: true,
             client_inv_type_child: false,
             client_inv_type_def_counter: false,
             client_inv_type_defend_procs: false,
             client_inv_type_interpleader: false,
             client_inv_type_intervenor: false,
             client_inv_type_joined_party: false,
             client_inv_type_other: false,
             client_inv_type_personal_rep: false,
             client_involvement_type: 'A',
             client_involvement: 'Applicant/Claimant/Petitioner',
             counsel_fee_family: 0.0,
             damages_against_police: 'No',
             default_level_of_service: 1,
             delegated_functions_date: Date.new(2019, 4, 1),
             description: 'to be represented on an application for a child arrangements order ?where the child(ren) will live',
             disbursement_cost_family: 0.0,
             dom_violence_waiver_applies: 'No',
             dv_gateway_applies?: true,
             expert_cost_family: 0.0,
             family_prospects_of_success: '50% or Better',
             fam_prosp_50_or_better: true,
             fam_prosp_border_uncert_poor: false,
             fam_prosp_borderline_uncert: false,
             fam_prosp_good: false,
             fam_prosp_marginal: false,
             fam_prosp_poor: false,
             fam_prosp_uncertain: false,
             fam_prosp_very_good: false,
             fam_prosp_very_poor: false,
             fin_rep_category: 'Private Law Children',
             generate_bail_conditions_set_block?: false,
             generate_child_parties_criteria_block?: true,
             generate_inj_respondent_capacity_block?: false,
             generate_injunction_reason_no_warning_letter_block?: false,
             generate_injunction_recent_incident_detail_block?: false,
             generate_police_notified_block?: false,
             generate_warning_letter_sent_block?: false,
             generate_work_in_scheme_1_block?: true,
             generate_x_border_lar_criteria_block?: true,
             high_cost_case_routing: 'VHCC',
             immigration_related: false,
             immigration_question_applies: 'No',
             includes_child: 'Yes',
             inj_respondent_capacity?: true,
             injunction_recent_incident_detail: '29/03/2019',
             involving_children: 'Yes',
             involving_injunction: 'No',
             judicial_review: false,
             lar_gateway?: true,
             lead_proceeding?: false,
             lead_proceeding_indicator: false,
             lead_proceeding_merits?: false,
             level_of_service: 3,
             level_of_service_fhh: false,
             level_of_service_fr: true,
             level_of_serv_ih: false,
             level_of_serv_inquest: false,
             limitation_desc: 'MULTIPLE',
             matrimonial_proceeding: 'No',
             matter_type_child_abduction: 'No',
             matter_type_meaning: 'Section 8 orders',
             matter_type_private_family: 'Yes',
             matter_type_public_family: 'No',
             matter_type_stand_alone: 'No',
             meaning: 'CAO residence',
             new_or_existing: 'NEW',
             new_or_existing_merits: 'NEW',
             non_quantifiable_remedy: false,
             outcome_no_outcome: true,
             overwhelming_importance: false,
             police_notified?: true,
             predicted_cost_family: 5000.0,
             private_funding_applicable: false,
             private_funding_considered: 'No',
             proc_care_superv_or_related: 'No',
             proc_involving_fin_and_prop: 'No',
             proc_is_merits_tested: 'Yes',
             proc_is_sca_or_related: 'No',
             proc_is_sca_appeal: false,
             proc_outcome_recorded: false,
             proc_possession: 'No',
             proc_register_foreign_order: 'No',
             proc_related_sca_or_related: false,
             proc_subject_to_dp_check: 'Yes',
             proc_subject_to_mediation: 'Yes',
             proc_upper_tribunal: 'No',
             proceeding_application_type: 'Both',
             proceeding_case_owner_scu: false,
             proceeding_level_of_service: 'Full Representation',
             proceeding_limitation_meaning: 'MULTIPLE',
             proceeding_new_or_existing: 'NEW',
             proceeding_stand_alone: 'No',
             proceeding_type: 'proc error',
             profit_cost_family: 5_000.0,
             proportionality_question: 'No',
             prospects_of_success: 'FA',
             reason_no_injunction_warning_letter: 'Too dangerous',
             related_proceeding: false,
             related_sca_or_related: false,
             requested_scope: 'MULTIPLE',
             routing_for_proceeding: 'Standard Family Merits',
             sca_appeal_final_order: false,
             schedule_1?: true,
             scope_limit_is_default: false,
             scope_limitations: [scope_limitation_1, scope_limitation_3],
             significant_wider_public_interest: false,
             smod_applicable: 'No',
             status: 'draft',
             warning_letter_sent?: false,
             work_in_scheme_1?: true,
             x_border_disputes_lar_criteria?: false
    end

    let(:scope_limitation_1) do
      double 'ScopeLimitation',
             limitation: 'CV118',
             wording: 'Limited to all steps up to and including the hearing on 01/04/2019',
             delegated_functions_apply: true
    end

    let(:scope_limitation_2) do
      double 'ScopeLimitation',
             limitation: 'AA019',
             wording: scope_limitation_wording_2,
             delegated_functions_apply: false
    end

    let(:scope_limitation_3) do
      double 'ScopeLimitation',
             limitation: 'FM049',
             wording: scope_limitation_wording_3,
             delegated_functions_apply: false
    end

    let(:opponents) { [opponent_1, opponent_2] }

    let(:opponent_1) do
      double 'Person',
             title: 'MR',
             first_name: 'Dummy',
             surname: 'Opponent',
             date_of_birth: Date.new(1953, 8, 13),
             relation_to_client: 'EX_SPOUSE',
             relation_to_case: 'OPP',
             civil_partner?: false
    end

    let(:opponent_2) do
      double 'Person',
             title: 'MASTER',
             surname: 'Bonstart',
             first_name: 'Stepriponikas',
             date_of_birth: Date.new(1953, 8, 13),
             relation_to_client: 'CHILD',
             relation_to_case: 'CHILD'
    end

    let(:other_party_1) { create :opponent, :child }

    let(:other_party_2)  { create :opponent, :ex_spouse }

    let(:bank_account) do
      double BankAccount,
             bank_provider: bank_provider,
             balance: 100.0,
             account_number: 12_345_678,
             holders: 'ClientSole',
             account_type_label: 'Bank Current',
             display_name: 'the bank account1',
             receives_tax_credits?: false,
             receives_wages?: true,
             receives_benefits?: true
    end

    let(:bank_provider) do
      double BankProvider, name: 'Mock bank'
    end

    let(:vehicle) do
      double Vehicle,
             purchased_on: Date.new(2015, 12, 1),
             used_regularly?: true,
             estimated_value: 5_000.0,
             payment_remaining: 0.0
    end

    let(:wage_slip) do
      double 'WageSlip',
             ni_deducted: 100,
             gross_pay: 1000,
             paye_deducted: 300,
             pay_period: Date.new(2019, 3, 29),
             description: '300000333864:EMPLOYMENT_CLIENT_001:CLI_NON_HM_WAGE_SLIP_001'
    end

    let(:provider) do
      double 'Provider',
             firm_id: 22_381,
             office_id: 81_693,
             user_login_id: 2_016_472,
             supervisor_contact_id: 3_982_723,
             fee_earner_contact_id: 34_419
    end

    before do
      allow_any_instance_of(LegalAidApplication).to receive(:proceeding_types).and_return([proceeding_type_1, proceeding_type_2])
      allow_any_instance_of(LegalAidApplication).to receive(:opponents).and_return([other_party_2])
      allow_any_instance_of(LegalAidApplication).to receive(:vehicle).and_return(vehicle)
      allow_any_instance_of(LegalAidApplication).to receive(:wage_slips).and_return([wage_slip])
      allow_any_instance_of(LegalAidApplication).to receive(:opponent_other_parties).and_return([other_party_2, other_party_1])
      allow_any_instance_of(LegalAidApplication).to receive(:provider).and_return(provider)
      allow_any_instance_of(Applicant).to receive(:bank_accounts).and_return([bank_account])
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

    describe 'generate case payload only' do
      before do
        @submission.aasm_state = 'applicant_ref_obtained'
      end

      it 'generates the CaseAdd payload' do
        if RSpec.configuration.run_ccms_integration_specs?
          ENV['CCMS_PAYLOAD_GENERATION_ONLY'] = '1'
          # stub ccms case reference as we're  not going through the whole path so it won't be generated
          allow_any_instance_of(CCMS::Submission).to receive(:case_ccms_reference).and_return('300000333864')
          @submission.process!
        end
      end
    end

    describe 'complete sequence' do
      it 'runs one thing after another' do
        if RSpec.configuration.run_ccms_integration_specs?
          check_initial_state
          request_case_id
          create_an_applicant
          poll_applicant_creation
          create_case
          poll_case_creation_result
        end
      end
    end

    def history
      SubmissionHistory.where(submission_id: @submission.id).order(created_at: :desc).first
    end

    def check_initial_state
      print 'checking initial state.... '
      expect(@submission.aasm_state).to eq 'initialised'
      puts "'initialised'".green
    end

    def request_case_id
      print 'Getting case id... '
      @submission.process!
      expect(@submission.case_ccms_reference).not_to be_nil
      expect(@submission.aasm_state).to eq 'case_ref_obtained'
      expect(history.from_state).to eq 'initialised'
      expect(history.to_state).to eq 'case_ref_obtained'
      expect(history.success).to be true
      puts @submission.case_ccms_reference.green
    end

    def create_an_applicant
      print 'Applicant submitted... '
      expect {
        @submission.process!
      }.not_to change{ @submission.case_ccms_reference }
      expect(@submission.applicant_add_transaction_id).not_to be_nil
      expect(@submission.aasm_state).to eq 'applicant_submitted'
      history.reload
      expect(history.from_state).to eq 'case_ref_obtained'
      expect(history.to_state).to eq 'applicant_submitted'
      expect(history.success).to be true
      expect(history.details).to be_nil
      puts 'done'.green
    end

    def poll_applicant_creation
      print 'Polling applicant creation result... '
      expect { @submission.process! }.to change { @submission.applicant_poll_count }.by(1) while @submission.applicant_ccms_reference.nil?

      expect(@submission.applicant_ccms_reference).not_to be_nil
      expect(@submission.aasm_state).to eq 'applicant_ref_obtained'
      expect(history.from_state).to eq 'applicant_submitted'
      expect(history.to_state).to eq 'applicant_ref_obtained'
      expect(history.success).to be true
      expect(history.details).to be_nil
      puts "Applicant reference #{@submission.applicant_ccms_reference} in #{@submission.applicant_poll_count} attempts.".green
    end

    def create_case
      print 'Submitting case... '
      @submission.process!
      expect(@submission.aasm_state).to eq 'case_submitted'
      expect(history.from_state).to eq 'applicant_ref_obtained'
      expect(history.to_state).to eq 'case_submitted'
      expect(history.success).to be true
      expect(history.details).to be_nil
      puts 'done'.green
    end

    def poll_case_creation_result
      poll_count = 0
      print 'Polling for case creation result'
      while @submission.aasm_state != 'case_created'
        print '...'
        $stdout.flush
        poll_count += 1
        sleep(5)
        @submission.reload.process!
      end

      puts " case created in #{poll_count} attempts".green
      expect(@submission.case_poll_count).to eq poll_count
      expect(@submission.applicant_ccms_reference).not_to be_nil
      expect(@submission.aasm_state).to eq 'case_created'
      expect(history.from_state).to eq 'case_submitted'
      expect(history.to_state).to eq 'case_created'
      expect(history.success).to be true
      expect(history.details).to be_nil
    end

    def scope_limitation_wording_2
      'As to proceedings under Part IV Family Law Act 1996 limited to all steps up to ' \
        'and including obtaining and serving a final order and in the event of breach ' \
        'leading to the exercise of a power of arrest to representation on the ' \
        'consideration of the breach by the court (but excluding applying for a warrant ' \
        'of arrest, if not attached, and representation in contempt proceedings).'
    end

    def scope_limitation_wording_3
      'Limited to all steps up to and including trial/final hearing and any action ' \
        'necessary to implement (but not enforce) the judgment or order.'
    end
  end

  #   describe 'initial state' do
  #     it 'creates a submission in the initial state' do
  #       expect(@submission.aasm_state).to eq 'initialised'
  #     end
  #   end
  #
  #   describe 'getting a case id' do
  #     it 'stores the reference number, updates the state, and writes a history record' do
  #       @submission.process!
  #       expect(@submission.case_ccms_reference).not_to be_nil
  #       expect(@submission.aasm_state).to eq 'case_ref_obtained'
  #       expect(history.from_state).to eq 'initialised'
  #       expect(history.to_state).to eq 'case_ref_obtained'
  #       expect(history.success).to be true
  #       expect(history.details).to be_nil
  #     end
  #   end
  #
  #   describe 'creating an applicant' do
  #     it 'stores the transaction_id, updates the state and writes a history record' do
  #       expect { @submission.process! }.not_to change { @submission.case_ccms_reference }
  #       expect(@submission.applicant_add_transaction_id).not_to be_nil
  #       expect(@submission.aasm_state).to eq 'applicant_submitted'
  #       expect(history.from_state).to eq 'case_ref_obtained'
  #       expect(history.to_state).to eq 'applicant_submitted'
  #       expect(history.success).to be true
  #       expect(history.details).to be_nil
  #     end
  #   end
  #
  #   describe 'polling for applicant creation' do
  #     it 'stores the applicant_id, updates the state and writes a history record' do
  #       expect { @submission.process! }.to change { @submission.applicant_poll_count }.by(1) while @submission.applicant_ccms_reference.nil?
  #
  #       expect(@submission.applicant_ccms_reference).not_to be_nil
  #       expect(@submission.aasm_state).to eq 'applicant_ref_obtained'
  #       expect(history.from_state).to eq 'applicant_submitted'
  #       expect(history.to_state).to eq 'applicant_ref_obtained'
  #       expect(history.success).to be true
  #       expect(history.details).to be_nil
  #     end
  #   end
  #
  #   describe 'creating a case' do
  #     it 'stores the transaction_id, updates the state and writes a history record' do
  #       @submission.process!
  #       expect(@submission.aasm_state).to eq 'case_submitted'
  #       expect(history.from_state).to eq 'applicant_ref_obtained'
  #       expect(history.to_state).to eq 'case_submitted'
  #       expect(history.success).to be true
  #       expect(history.details).to be_nil
  #     end
  #   end
  #
  #   describe 'polling for case creation' do
  #     it 'updates the state and writes a history record' do
  #       while @submission.aasm_state != 'case_created'
  #         sleep(10)
  #         expect { @submission.process! }.to change { @submission.case_poll_count }.by(1)
  #       end
  #
  #       expect(@submission.applicant_ccms_reference).not_to be_nil
  #       expect(@submission.aasm_state).to eq 'case_created'
  #       expect(history.from_state).to eq 'case_submitted'
  #       expect(history.to_state).to eq 'case_created'
  #       expect(history.success).to be true
  #       expect(history.details).to be_nil
  #     end
  #   end
  #
  #   describe 'getting document ids' do
  #     # context 'there are no documents' do
  #     #   it 'updates the state and writes a history record' do
  #     #     @submission.process!
  #     #     expect(@submission.documents).to be_empty
  #     #     expect(@submission.aasm_state).to eq 'completed'
  #     #     expect(history.from_state).to eq 'case_created'
  #     #     expect(history.to_state).to eq 'completed'
  #     #     expect(history.success).to be true
  #     #     expect(history.details).to be_nil
  #     #   end
  #     # end
  #
  #     context 'there are documents' do
  #       it 'populates the document list, stores document_ids, updates the state and writes a history record' do
  #         @submission.process!
  #         expect(@submission.documents).to_not be_empty
  #         expect(@submission.documents.values[0]).to eq :id_obtained
  #         expect(@submission.aasm_state).to eq 'document_ids_obtained'
  #         expect(history.from_state).to eq 'case_created'
  #         expect(history.to_state).to eq 'document_ids_obtained'
  #         expect(history.success).to be true
  #         expect(history.details).to be_nil
  #       end
  #     end
  #
  #     describe 'uploading documents' do
  #       it 'updates the state and writes a history record' do
  #         @submission.process!
  #         expect(@submission.documents.values[0]).to eq :uploaded
  #         expect(@submission.aasm_state).to eq 'completed'
  #         expect(history.from_state).to eq 'document_ids_obtained'
  #         expect(history.to_state).to eq 'completed'
  #         expect(history.success).to be true
  #         expect(history.details).to be_nil
  #       end
  #     end
  #   end
  # end
end
