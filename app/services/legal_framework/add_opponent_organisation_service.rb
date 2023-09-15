module LegalFramework
  class AddOpponentOrganisationService
    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call(lfa_organisation)
      ActiveRecord::Base.transaction do
        organisation = ApplicationMeritsTask::Organisation.create!(
          name: lfa_organisation.name,
          ccms_type_code: lfa_organisation.ccms_type_code,
          ccms_type_text: lfa_organisation.ccms_type_text,
        )

        ApplicationMeritsTask::Opponent.create!(
          legal_aid_application_id: @legal_aid_application.id,
          ccms_opponent_id: lfa_organisation.ccms_opponent_id,
          opposable_type: ApplicationMeritsTask::Organisation.to_s,
          opposable_id: organisation.id,
        )
      end

      true
    end
  end
end
