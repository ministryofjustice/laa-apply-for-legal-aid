# assigns the first domestic abuse proceeding type as lead if one isn't assigned already
# not an error condition if there are no domestic abuse proceedings.
#
class LeadProceedingAssignmentService
  def self.call(legal_aid_application)
    new(legal_aid_application).call
  end

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application.reload
  end

  def call
    return if @legal_aid_application.application_proceeding_types.empty?

    lead = @legal_aid_application.application_proceeding_types.find_by(lead_proceeding: true)
    assign_new_lead if lead.nil?
  end

  private

  def assign_new_lead
    pt = @legal_aid_application.proceeding_types.detect(&:domestic_abuse?)
    return if pt.nil?

    apt = @legal_aid_application.application_proceeding_types.find_by(proceeding_type_id: pt.id)
    apt.update!(lead_proceeding: true)
  end
end
