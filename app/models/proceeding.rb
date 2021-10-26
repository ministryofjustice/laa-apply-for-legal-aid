class Proceeding < ApplicationRecord
  belongs_to :legal_aid_application

  has_one :attempts_to_settle, class_name: 'ProceedingMeritsTask::AttemptsToSettle', dependent: :destroy

  has_one :chances_of_success, class_name: 'ProceedingMeritsTask::ChancesOfSuccess', dependent: :destroy

  has_many :proceeding_linked_children, class_name: 'ProceedingMeritsTask::ProceedingLinkedChild', dependent: :destroy

  has_many :involved_children,
           through: :proceeding_linked_children,
           source: :involved_child

  # TODO: remove once migration from application_proceeding_types to proceedings is completed
  #
  # temporary method to create test data from existing proceeding types
  # to be removed when application_proceeding_types are removed
  def self.create_from_proceeding_type(application, proceeding_type) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    create legal_aid_application_id: application.id,
           ccms_code: proceeding_type.ccms_code,
           meaning: proceeding_type.meaning,
           description: proceeding_type.description,
           substantive_cost_limitation: proceeding_type.default_cost_limitation_substantive,
           delegated_functions_cost_limitation: proceeding_type.default_cost_limitation_delegated_functions,
           substantive_scope_limitation_code: proceeding_type.default_substantive_scope_limitation.code,
           substantive_scope_limitation_meaning: proceeding_type.default_substantive_scope_limitation.meaning,
           substantive_scope_limitation_description: proceeding_type.default_substantive_scope_limitation.description,
           delegated_functions_scope_limitation_code: proceeding_type.default_delegated_functions_scope_limitation.code,
           delegated_functions_scope_limitation_meaning: proceeding_type.default_delegated_functions_scope_limitation.meaning,
           delegated_functions_scope_limitation_description: proceeding_type.default_delegated_functions_scope_limitation.description,
           used_delegated_functions_on: nil,
           used_delegated_functions_reported_on: nil,
           name: proceeding_type.name
  end
end
