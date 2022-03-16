# assigns the first domestic abuse proceeding type as lead if one isn't assigned already
# not an error condition if there are no domestic abuse proceedings.
#
module LegalFramework
  class LeadProceedingAssignmentService
    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application.reload
    end

    def call
      return if @legal_aid_application.proceedings.empty?

      lead = @legal_aid_application.proceedings.find_by(lead_proceeding: true)
      assign_new_lead if lead.nil?
    end

  private

    def assign_new_lead
      new_lead_proceeding = @legal_aid_application.proceedings.detect(&:domestic_abuse?)
      return if new_lead_proceeding.nil?

      new_lead_proceeding.update!(lead_proceeding: true)
    end
  end
end
