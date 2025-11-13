class Proceeding < ApplicationRecord
  FIRST_PROCEEDING_CASE_ID = 55_000_000

  belongs_to :legal_aid_application

  has_one :opponents_application, class_name: "ProceedingMeritsTask::OpponentsApplication", dependent: :destroy
  has_one :attempts_to_settle, class_name: "ProceedingMeritsTask::AttemptsToSettle", dependent: :destroy
  has_one :specific_issue, class_name: "ProceedingMeritsTask::SpecificIssue", dependent: :destroy
  has_one :vary_order, class_name: "ProceedingMeritsTask::VaryOrder", dependent: :destroy

  has_one :chances_of_success, class_name: "ProceedingMeritsTask::ChancesOfSuccess", dependent: :destroy
  has_one :prohibited_steps, class_name: "ProceedingMeritsTask::ProhibitedSteps", dependent: :destroy
  has_one :child_care_assessment, class_name: "ProceedingMeritsTask::ChildCareAssessment", dependent: :destroy

  has_many :final_hearings, dependent: :destroy
  has_many :proceeding_linked_children, class_name: "ProceedingMeritsTask::ProceedingLinkedChild", dependent: :destroy

  has_many :involved_children,
           through: :proceeding_linked_children,
           source: :involved_child

  has_many :scope_limitations, dependent: :destroy

  scope :in_order_of_addition, -> { order(:created_at) }
  scope :using_delegated_functions, -> { where(used_delegated_functions: true).where.not(used_delegated_functions_on: nil).order(:used_delegated_functions_on) }
  scope :not_using_delegated_functions, -> { where.not(used_delegated_functions: true) }

  before_create do
    self.proceeding_case_id = highest_proceeding_case_id + 1 if proceeding_case_id.blank?
  end

  def pretty_df_date
    used_delegated_functions_on&.strftime("%F") || "n/a"
  end

  def used_delegated_functions?
    used_delegated_functions.eql?(true) && used_delegated_functions_on.present?
  end

  def case_p_num
    "P_#{proceeding_case_id}"
  end

  def section8?
    ccms_matter_code == "KSEC8"
  end

  def substantive_scope_limitations
    scope_limitations.where(scope_type: :substantive)
  end

  def emergency_scope_limitations
    scope_limitations.where(scope_type: :emergency)
  end

  def highest_proceeding_case_id
    rec = self.class.order(proceeding_case_id: :desc).first
    rec.nil? || rec.proceeding_case_id.nil? ? FIRST_PROCEEDING_CASE_ID : rec.proceeding_case_id
  end

  def proceeding_case_p_num
    "P_#{proceeding_case_id}"
  end

  def special_children_act?
    ccms_matter_code == "KPBLW"
  end

  def domestic_abuse?
    ccms_matter_code == "MINJN"
  end

  def non_sca_used_delegated_functions?
    used_delegated_functions? && !special_children_act?
  end
end
