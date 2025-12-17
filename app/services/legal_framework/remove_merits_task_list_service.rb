module LegalFramework
  class RemoveMeritsTaskListService
    APPLICATION_MERITS = %i[
      allegation
      domestic_abuse_summary
      latest_incident
      matter_opposition
      parties_mental_capacity
      statement_of_case
      undertaking
      urgency
      appeal
    ].freeze

    PROCEEDING_MERITS = %i[
      opponents_application
      attempts_to_settle
      specific_issue
      vary_order
      chances_of_success
      prohibited_steps
      child_care_assessment
    ].freeze

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      @legal_aid_application.legal_framework_merits_task_list&.destroy!
      remove_application_merits!
      @legal_aid_application.proceedings&.each { |proceeding| remove_proceeding_merits!(proceeding) }
    end

  private

    def remove_application_merits!
      APPLICATION_MERITS.each { |merit| @legal_aid_application.send(merit)&.destroy! }
      @legal_aid_application.update!(in_scope_of_laspo: nil)
      @legal_aid_application.opponents&.destroy_all
      @legal_aid_application.involved_children&.destroy_all
    end

    def remove_proceeding_merits!(proceeding)
      PROCEEDING_MERITS.each { |merit| proceeding.send(merit)&.destroy! }
      proceeding.proceeding_linked_children&.destroy_all
    end
  end
end
