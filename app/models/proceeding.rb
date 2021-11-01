class Proceeding < ApplicationRecord
  belongs_to :legal_aid_application

  has_one :attempts_to_settle, class_name: 'ProceedingMeritsTask::AttemptsToSettle', dependent: :destroy

  has_one :chances_of_success, class_name: 'ProceedingMeritsTask::ChancesOfSuccess', dependent: :destroy

  has_many :proceeding_linked_children, class_name: 'ProceedingMeritsTask::ProceedingLinkedChild', dependent: :destroy

  has_many :involved_children,
           through: :proceeding_linked_children,
           source: :involved_child

  scope :in_order_of_addition, -> { order(:created_at) }
  scope :using_delegated_functions, -> { where.not(used_delegated_functions_on: nil).order(:used_delegated_functions_on) }
  scope :not_using_delegated_functions, -> { where(used_delegated_functions_on: nil) }

  def pretty_df_date
    used_delegated_functions_on&.strftime('%F') || 'n/a'
  end

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
           name: proceeding_type.name,
           matter_type: proceeding_type.ccms_matter,
           category_of_law: proceeding_type.ccms_category_law,
           category_law_code: proceeding_type.ccms_category_law_code,
           ccms_matter_code: proceeding_type.ccms_matter_code
  end

  def case_p_num
    "P_#{proceeding_case_id}"
  end

  def section8?
    ccms_matter_code == 'KSEC8'
  end

  def default_level_of_service_level
    '3'
  end

  def default_level_of_service_name
    'Full Representation'
  end

  def used_delegated_functions?
    used_delegated_functions_on.present?
  end

  # TODO: remove once LFA migration complete
  #
  # temporary method to return the corresponding application_proceeding_type
  def application_proceeding_type
    proceeding_type = ProceedingType.find_by ccms_code: ccms_code
    legal_aid_application.application_proceeding_types.find_by(proceeding_type_id: proceeding_type.id)
  end
end
