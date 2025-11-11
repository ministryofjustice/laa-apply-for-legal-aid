class ProceedingJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      legal_aid_application_id:,
      proceeding_case_id:,
      lead_proceeding:,
      ccms_code:,
      meaning:,
      description:,
      substantive_cost_limitation:,
      delegated_functions_cost_limitation:,
      used_delegated_functions_on:,
      used_delegated_functions_reported_on:,
      created_at:,
      updated_at:,
      name:,
      matter_type:,
      category_of_law:,
      category_law_code:,
      ccms_matter_code:,
      client_involvement_type_ccms_code:,
      client_involvement_type_description:,
      used_delegated_functions:,
      emergency_level_of_service:,
      emergency_level_of_service_name:,
      emergency_level_of_service_stage:,
      substantive_level_of_service:,
      substantive_level_of_service_name:,
      substantive_level_of_service_stage:,
      accepted_emergency_defaults:,
      accepted_substantive_defaults:,
      sca_type:,
      related_orders:,

      # nested relations below this line
      scope_limitations: scope_limitations.map { |sl| ScopeLimitationJsonBuilder.build(sl).as_json },

      # merits
      opponents_application: OpponentsApplicationJsonBuilder.build(opponents_application),
      attempts_to_settle: AttemptsToSettleJsonBuilder.build(attempts_to_settle),
      specific_issue: SpecificIssueJsonBuilder.build(specific_issue),
      vary_order: VaryOrderJsonBuilder.build(vary_order),
      chances_of_success: ChancesOfSuccessJsonBuilder.build(chances_of_success),
      prohibited_steps: ProhibitedStepsJsonBuilder.build(prohibited_steps),
      child_care_assessment: ChildCareAssessmentJsonBuilder.build(child_care_assessment),

      final_hearings: final_hearings.map { |fh| FinalHearingJsonBuilder.build(fh) },
      proceeding_linked_children: proceeding_linked_children.map { |lc| ProceedingLinkedChildJsonBuilder.build(lc) },
      involved_children: involved_children.map { |ic| InvolvedChildJsonBuilder.build(ic) },

      # has_one :opponents_application, class_name: "ProceedingMeritsTask::OpponentsApplication", dependent: :destroy
      # has_one :attempts_to_settle, class_name: "ProceedingMeritsTask::AttemptsToSettle", dependent: :destroy
      # has_one :specific_issue, class_name: "ProceedingMeritsTask::SpecificIssue", dependent: :destroy
      # has_one :vary_order, class_name: "ProceedingMeritsTask::VaryOrder", dependent: :destroy

      # has_one :chances_of_success, class_name: "ProceedingMeritsTask::ChancesOfSuccess", dependent: :destroy
      # has_one :prohibited_steps, class_name: "ProceedingMeritsTask::ProhibitedSteps", dependent: :destroy
      # has_one :child_care_assessment, class_name: "ProceedingMeritsTask::ChildCareAssessment", dependent: :destroy

      # has_many :final_hearings, dependent: :destroy
      # has_many :proceeding_linked_children, class_name: "ProceedingMeritsTask::ProceedingLinkedChild", dependent: :destroy

      # has_many :involved_children,
      #          through: :proceeding_linked_children,
      #          source: :involved_child

      # has_many :scope_limitations, dependent: :destroy
    }
  end
end
