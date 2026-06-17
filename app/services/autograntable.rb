class Autograntable
  AUTOGRANTABLE_PROCEEDING_CCMS_CODES = %w[PB003 PB004 PB005 PB006 PB026 PB057 PB059].freeze

  attr_reader :legal_aid_application

  delegate :special_children_act_proceedings?,
           :proceedings,
           :core_proceedings,
           :applicant,
           :applicant_over_17?,
           :special_children_act_related_proceedings?,
           :client_court_ordered_parental_responsibility?,
           :client_parental_responsibility_agreement?, to: :legal_aid_application

  def self.call(legal_aid_application)
    new(legal_aid_application).call
  end

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  def call
    autograntable_special_childrens_act_proceedings? && auto_grant_exclusions?
  end

private

  def autograntable_special_childrens_act_proceedings?
    return false unless special_children_act_proceedings?

    single_autograntable_core_proceeding? || care_order_supervision_order_application?
  end

  def single_autograntable_core_proceeding?
    core_proceedings.one? && AUTOGRANTABLE_PROCEEDING_CCMS_CODES.include?(core_proceedings.first.ccms_code)
  end

  def care_order_supervision_order_application?
    !core_proceedings.empty? && core_proceedings.all? { |proceeding| %w[PB057 PB059].include?(proceeding.ccms_code) }
  end

  def auto_grant_exclusions?
    # If any of these are true then auto-granting should not occur
    # This list is not definitive, it is accurate for the initial release of SCA, Oct 2024
    # e.g. when Apply starts handling high-cost cases we could add a test for claims > £25,000
    [
      special_children_act_related_proceedings?,
      client_court_ordered_parental_responsibility?,
      client_parental_responsibility_agreement?,
      special_children_act_child_subject_over_17?,
    ].none?
  end

  def special_children_act_child_subject_over_17?
    sca_care_order_or_supervision_order_child_subject? && applicant.over_17?
  end

  def sca_care_order_or_supervision_order_child_subject?
    proceedings.any? { |proceeding| proceeding.ccms_code.in?(%w[PB057 PB059]) && proceeding.client_involvement_type_ccms_code.eql?("W") }
  end
end
