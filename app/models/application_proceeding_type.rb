class ApplicationProceedingType < ApplicationRecord
  FIRST_PROCEEDING_CASE_ID = 55_000_000

  belongs_to :legal_aid_application
  belongs_to :proceeding_type
  has_many :application_proceeding_types_scope_limitations, dependent: :destroy
  has_many :application_proceeding_type_involved_children, class_name: 'ProceedingMeritsTask::ApplicationProceedingTypeInvolvedChild', dependent: :destroy

  has_many :involved_children,
           through: :application_proceeding_types_involved_children,
           source: :involved_child

  has_many :assigned_scope_limitations,
           through: :application_proceeding_types_scope_limitations,
           source: :scope_limitation

  has_one :substantive_scope_limitation_join, class_name: 'AssignedSubstantiveScopeLimitation', dependent: :destroy

  has_one :substantive_scope_limitation, through: :substantive_scope_limitation_join, source: :scope_limitation

  has_one :delegated_functions_scope_limitation_join, class_name: 'AssignedDfScopeLimitation', dependent: :destroy

  has_one :delegated_functions_scope_limitation, through: :delegated_functions_scope_limitation_join, source: :scope_limitation

  delegate :default_substantive_scope_limitation,
           :default_delegated_functions_scope_limitation,
           to: :proceeding_type

  before_create do
    self.proceeding_case_id = highest_proceeding_case_id + 1 if proceeding_case_id.blank?
    self.lead_proceeding = true if proceedings.empty?
  end

  def add_default_substantive_scope_limitation
    new_scope_limitation = AssignedSubstantiveScopeLimitation.new(scope_limitation: default_substantive_scope_limitation)
    add_scope_limitation_unless_duplicate new_scope_limitation
  end

  def add_default_delegated_functions_scope_limitation
    new_scope_limitation = AssignedDfScopeLimitation.new(scope_limitation: default_delegated_functions_scope_limitation)
    add_scope_limitation_unless_duplicate new_scope_limitation
  end

  def add_scope_limitation_unless_duplicate(new_scope_limitation)
    duplicated = application_proceeding_types_scope_limitations.map(&:scope_limitation_id).include?(new_scope_limitation.scope_limitation_id)
    application_proceeding_types_scope_limitations << new_scope_limitation unless duplicated
  end

  def remove_default_delegated_functions_scope_limitation
    delegated_functions_scope_limitation_join&.destroy!
  end

  def proceeding_case_p_num
    "P_#{proceeding_case_id}"
  end

  private

  def highest_proceeding_case_id
    rec = self.class.order(proceeding_case_id: :desc).first
    rec.nil? || rec.proceeding_case_id.nil? ? FIRST_PROCEEDING_CASE_ID : rec.proceeding_case_id
  end

  def proceedings
    ApplicationProceedingType.where(legal_aid_application_id: legal_aid_application.id)
  end
end
