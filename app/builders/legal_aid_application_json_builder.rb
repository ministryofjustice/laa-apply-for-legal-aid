class LegalAidApplicationJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      application_ref:,
      created_at:,
      updated_at:,
      applicant_id:,
      has_offline_accounts:,
      open_banking_consent:,
      open_banking_consent_choice_at:,
      own_home:,
      property_value:,
      shared_ownership:,
      outstanding_mortgage_amount:,
      percentage_home:,
      provider_step:,
      provider_id:,
      draft:,
      transaction_period_start_on:,
      transaction_period_finish_on:,
      transactions_gathered:,
      completed_at:,
      declaration_accepted_at:,
      provider_step_params:,
      own_vehicle:,
      substantive_application_deadline_on:,
      substantive_application:,
      has_dependants:,
      office_id:,
      has_restrictions:,
      restrictions_details:,
      no_credit_transaction_types_selected:,
      no_debit_transaction_types_selected:,
      provider_received_citizen_consent:,
      discarded_at:,
      merits_submitted_at:,
      in_scope_of_laspo:,
      emergency_cost_override:,
      emergency_cost_requested:,
      emergency_cost_reasons:,
      no_cash_income:,
      no_cash_outgoings:,
      purgeable_on:,
      allowed_document_categories:,
      extra_employment_information:,
      extra_employment_information_details:,
      full_employment_details:,
      client_declaration_confirmed_at:,
      substantive_cost_override:,
      substantive_cost_requested:,
      substantive_cost_reasons:,
      applicant_in_receipt_of_housing_benefit:,
      copy_case:,
      copy_case_id:,
      case_cloned:,
      separate_representation_required:,
      plf_court_order:,
      reviewed:,
      dwp_result_confirmed:,
      linked_application_completed:,

      # associations
      office: OfficeJsonBuilder.build(office),
      provider: ProviderJsonBuilder.build(provider),
      applicant: ApplicantJsonBuilder.build(applicant).as_json,
      partner: PartnerJsonBuilder.build(partner).as_json,
      proceedings: proceedings.map { |p| ProceedingJsonBuilder.build(p).as_json },
      all_linked_applications: all_linked_applications.map { |la| LinkedApplicationJsonBuilder.build(la).as_json }, # NOTE: one way of handling linked applications for now
      benefit_check_result: BenefitCheckResultJsonBuilder.build(benefit_check_result).as_json,
      dwp_override: DWPOverrideJsonBuilder.build(dwp_override).as_json,
      legal_framework_merits_task_list: LegalFrameworkMeritsTaskListJsonBuilder.build(legal_framework_merits_task_list).as_json,
      state_machine: StateMachineJsonBuilder.build(state_machine).as_json,
      hmrc_responses: hmrc_responses.map { |hr| HMRCResponseJsonBuilder.build(hr).as_json },
      employments: employments.map { |e| EmploymentJsonBuilder.build(e).as_json },

      # means
      other_assets_declaration: OtherAssetsDeclarationJsonBuilder.build(other_assets_declaration).as_json,
      savings_amount: SavingsAmountJsonBuilder.build(savings_amount).as_json,
      dependants: dependants.map { |d| DependantJsonBuilder.build(d).as_json },
      vehicles: vehicles.map { |v| VehicleJsonBuilder.build(v).as_json },
      capital_disregards: capital_disregards.map { |cd| CapitalDisregardJsonBuilder.build(cd).as_json },
      legal_aid_application_transaction_types: legal_aid_application_transaction_types.map { |latt| LegalAidApplicationTransactionTypeJsonBuilder.build(latt).as_json },
      regular_transactions: regular_transactions.map { |rt| RegularTransactionJsonBuilder.build(rt).as_json },
      cash_transactions: cash_transactions.map { |ct| CashTransactionJsonBuilder.build(ct).as_json },
      most_recent_cfe_submission: CFESubmissionJsonBuilder.build(most_recent_cfe_submission).as_json,

      # merits
      statement_of_case: StatementOfCaseJsonBuilder.build(statement_of_case).as_json,
      domestic_abuse_summary: DomesticAbuseSummaryJsonBuilder.build(domestic_abuse_summary).as_json,
      opponents: opponents.map { |o| OpponentJsonBuilder.build(o).as_json },
      parties_mental_capacity: PartiesMentalCapacityJsonBuilder.build(parties_mental_capacity).as_json,
      latest_incident: LatestIncidentJsonBuilder.build(latest_incident).as_json,
      allegation: AllegationJsonBuilder.build(allegation).as_json,
      undertaking: UndertakingJsonBuilder.build(undertaking).as_json,
      urgency: UrgencyJsonBuilder.build(urgency).as_json,
      appeal: AppealJsonBuilder.build(appeal).as_json,
      matter_opposition: MatterOppositionJsonBuilder.build(matter_opposition).as_json,
      involved_children: involved_children.map { |ic| InvolvedChildJsonBuilder.build(ic).as_json }, # DO WE NEEDS THIS AS IS PRESENT ON PROCEEDING LEVEL TOO
    }
  end

  # ---------------------
  # DONE
  # ---------------------
  #
  # ASSOCIATIONS
  # belongs_to :applicant, optional: true, dependent: :destroy
  # has_one :partner, dependent: :destroy
  # belongs_to :provider, optional: false
  # belongs_to :office, optional: true
  # has_many :proceedings, dependent: :destroy
  # has_one :state_machine, class_name: "BaseStateMachine", dependent: :destroy
  # has_many :hmrc_responses, class_name: "HMRC::Response", dependent: :destroy, inverse_of: :legal_aid_application
  # has_many :employments, dependent: :destroy
  # has_one :benefit_check_result, dependent: :destroy
  # has_one :dwp_override, dependent: :destroy
  # has_one :legal_framework_merits_task_list, class_name: "LegalFramework::MeritsTaskList", inverse_of: :legal_aid_application, dependent: :destroy
  #
  # MEANS
  # has_one :other_assets_declaration, dependent: :destroy
  # has_one :savings_amount, dependent: :destroy
  # has_many :dependants, dependent: :destroy
  # has_many :vehicles, dependent: :destroy
  # has_many :capital_disregards, dependent: :destroy
  # has_many :legal_aid_application_transaction_types, dependent: :destroy
  # has_many :transaction_types, through: :legal_aid_application_transaction_types
  # has_many :regular_transactions, dependent: :destroy
  # has_many :cash_transactions, dependent: :destroy
  # has_one :most_recent_cfe_submission, -> { order(created_at: :desc) }, class_name: "CFE::Submission", inverse_of: :legal_aid_application, dependent: :destroy

  # MERITS APPLICATION LEVEL
  # has_one :statement_of_case, class_name: "ApplicationMeritsTask::StatementOfCase", dependent: :destroy # NEED TO HANDLE S3 ATTACHEMENTS TOO
  # has_one :domestic_abuse_summary, class_name: "ApplicationMeritsTask::DomesticAbuseSummary", dependent: :destroy#
  # has_many :opponents, class_name: "ApplicationMeritsTask::Opponent", dependent: :destroy
  # has_one :parties_mental_capacity, class_name: "ApplicationMeritsTask::PartiesMentalCapacity", dependent: :destroy
  # has_one :latest_incident, -> { order(occurred_on: :desc) }, class_name: "ApplicationMeritsTask::Incident", inverse_of: :legal_aid_application, dependent: :destroy
  # has_one :allegation, class_name: "ApplicationMeritsTask::Allegation", dependent: :destroy
  # has_one :undertaking, class_name: "ApplicationMeritsTask::Undertaking", dependent: :destroy
  # has_one :urgency, class_name: "ApplicationMeritsTask::Urgency", dependent: :destroy
  # has_one :appeal, class_name: "ApplicationMeritsTask::Appeal", dependent: :destroy
  # has_one :matter_opposition, -> { order(created_at: :desc) }, class_name: "ApplicationMeritsTask::MatterOpposition", inverse_of: :legal_aid_application, dependent: :destroy
  # has_many :involved_children, class_name: "ApplicationMeritsTask::InvolvedChild", dependent: :destroy # DO WE NEEDS THIS AS IS PRESENT ON PROCEEDING LEVEL TOO

  # ---------------------
  # TODO
  # ---------------------
  #
  # ATTACHMENTS RELATED
  # ---------------------
  # has_many :attachments, dependent: :destroy
  # has_one :uploaded_evidence_collection, dependent: :destroy
  # has_one :bank_transaction_report, -> { where(attachment_type: "bank_transaction_report") }, class_name: "Attachment", inverse_of: :legal_aid_application, dependent: :destroy
  # has_one :merits_report, -> { where(attachment_type: "merits_report") }, class_name: "Attachment", inverse_of: :legal_aid_application, dependent: :destroy
  # has_one :means_report, -> { where(attachment_type: "means_report") }, class_name: "Attachment", inverse_of: :legal_aid_application, dependent: :destroy
  #
  # NOT NEEDED?
  # ---------------------
  # has_many :chances_of_success, through: :proceedings    # MERITS PROCEEDING LEVEL
  # has_many :attempts_to_settles, class_name: "ProceedingMeritsTask::AttemptsToSettle", through: :proceedings    # MERITS PROCEEDING LEVEL
  # has_one :ccms_submission, -> { order(created_at: :desc) }, class_name: "CCMS::Submission", inverse_of: :legal_aid_application, dependent: :destroy
  # has_one :policy_disregards, dependent: :destroy # THESE ARE OBSELETE - replaced by discretionary_capital_disregards and mandatory_capital_disregards
  # has_many :legal_framework_submissions, -> { order(created_at: :asc) }, class_name: "LegalFramework::Submission", inverse_of: :legal_aid_application, dependent: :destroy
  # has_many :scheduled_mailings, dependent: :destroy
  # has_many :cfe_submissions, -> { order(created_at: :asc) }, class_name: "CFE::Submission", inverse_of: :legal_aid_application, dependent: :destroy # WE SUPPLY ONLY THE most_recent_cfe_submission FOR NOW?!
  # has_many :discretionary_capital_disregards, -> { where(mandatory: "false") }, class_name: "CapitalDisregard"
  # has_many :mandatory_capital_disregards, -> { where(mandatory: "true") }, class_name: "CapitalDisregard"
  #
  # LINKED APPLICATIONS - NOT NEEDED? handled via all_linked_applications method above
  # ---------------------
  # has_one :lead_linked_application, class_name: "LinkedApplication", foreign_key: "associated_application_id", dependent: :destroy
  # has_one :lead_application, class_name: "LegalAidApplication", through: :lead_linked_application
  # has_one :target_application, class_name: "LegalAidApplication", through: :lead_linked_application
  # has_many :associated_linked_applications, class_name: "LinkedApplication", foreign_key: "lead_application_id", dependent: :destroy
  # has_many :associated_applications, class_name: "LegalAidApplication", through: :associated_linked_applications
end
