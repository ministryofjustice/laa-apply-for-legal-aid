class ApplicationProceedingType < ApplicationRecord
  FIRST_PROCEEDING_CASE_ID = 55_000_000

  belongs_to :legal_aid_application
  belongs_to :proceeding_type
  has_many :application_proceeding_types_scope_limitations, dependent: :destroy
  has_many :assigned_scope_limitations, through: :application_proceeding_types_scope_limitations, source: :scope_limitation

  before_create do
    self.proceeding_case_id = highest_proceeding_case_id + 1 if proceeding_case_id.blank?
  end

  def add_default_substantive_scope_limitation
    assigned_scope_limitations << proceeding_type.default_substantive_scope_limitation
  end

  def add_default_delegated_functions_scope_limitation
    assigned_scope_limitations << proceeding_type.default_delegated_functions_scope_limitation
  end

  def remove_default_delegated_functions_scope_limitation
    scope_limitation = proceeding_type.default_delegated_functions_scope_limitation
    assigned_scope_limitations.delete(scope_limitation)
  end

  def proceeding_case_p_num
    "P_#{proceeding_case_id}"
  end

  private

  def highest_proceeding_case_id
    rec = self.class.order(proceeding_case_id: :desc).first
    rec.nil? || rec.proceeding_case_id.nil? ? FIRST_PROCEEDING_CASE_ID : rec.proceeding_case_id
  end
end
