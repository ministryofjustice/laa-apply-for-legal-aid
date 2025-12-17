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

      # derived attributes
      auto_grant: auto_grant?,

      # associations
      office: OfficeJsonBuilder.build(office).as_json,
      provider: ProviderJsonBuilder.build(provider).as_json,
      firm: FirmJsonBuilder.build(provider.firm).as_json,
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

      # means: this will include open banking data belong to the applicant too, if available
      means: {
        open_banking: {
          bank_providers: applicant&.bank_providers&.map { |bp| BankProviderJsonBuilder.build(bp).as_json },
        },
        other_assets_declaration: OtherAssetsDeclarationJsonBuilder.build(other_assets_declaration).as_json,
        savings_amount: SavingsAmountJsonBuilder.build(savings_amount).as_json,
        dependants: dependants.map { |d| DependantJsonBuilder.build(d).as_json },
        vehicles: vehicles.map { |v| VehicleJsonBuilder.build(v).as_json },
        capital_disregards: capital_disregards.map { |cd| CapitalDisregardJsonBuilder.build(cd).as_json },
        legal_aid_application_transaction_types: legal_aid_application_transaction_types.map { |latt| LegalAidApplicationTransactionTypeJsonBuilder.build(latt).as_json },
        regular_transactions: regular_transactions.map { |rt| RegularTransactionJsonBuilder.build(rt).as_json },
        cash_transactions: cash_transactions.map { |ct| CashTransactionJsonBuilder.build(ct).as_json },
        most_recent_cfe_submission: CFESubmissionJsonBuilder.build(most_recent_cfe_submission).as_json,
      },

      # application (level) merits
      application_merits: {
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
      },

      # proceeding (level) merits
      proceeding_merits:
        proceedings.map do |p|
          {
            opponents_application: OpponentsApplicationJsonBuilder.build(p.opponents_application).as_json,
            attempts_to_settle: AttemptsToSettleJsonBuilder.build(p.attempts_to_settle).as_json,
            specific_issue: SpecificIssueJsonBuilder.build(p.specific_issue).as_json,
            vary_order: VaryOrderJsonBuilder.build(p.vary_order).as_json,
            chances_of_success: ChancesOfSuccessJsonBuilder.build(p.chances_of_success).as_json,
            prohibited_steps: ProhibitedStepsJsonBuilder.build(p.prohibited_steps).as_json,
            child_care_assessment: ChildCareAssessmentJsonBuilder.build(p.child_care_assessment).as_json,
            proceeding_linked_children: p.proceeding_linked_children.map { |lc| ProceedingLinkedChildJsonBuilder.build(lc).as_json },
            involved_children: p.involved_children.map { |ic| InvolvedChildJsonBuilder.build(ic).as_json }, # DO WE NEEDS THIS AS IS PRESENT ON APPLICATION LEVEL TOO
          }
        end,
    }
  end

private

  def auto_grant?
    auto_grant_special_children_act?
  end
end
