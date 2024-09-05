module Query
  class IncompleteProceedings
    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def call
      results = ActiveRecord::Base.connection.execute(query)
      Proceeding.where(id: results.values.flatten)
    end

  private

    def query
      <<~SQL.squish
        SELECT
            proceedings.id
        FROM proceedings
        WHERE (legal_aid_application_id='#{@legal_aid_application.id}')
        AND
        (
            NOT EXISTS (select 'has_scope_limitations' FROM scope_limitations where (proceeding_id = proceedings.id))
            OR (used_delegated_functions IS NULL)
            OR (accepted_substantive_defaults IS NULL AND ccms_matter_code != 'KPBLW')
            OR (client_involvement_type_ccms_code IS NULL)
            OR (used_delegated_functions = true AND accepted_emergency_defaults IS NULL AND ccms_matter_code != 'KPBLW')
            OR (accepted_substantive_defaults = false
                AND (substantive_level_of_service IS NULL
                    OR substantive_level_of_service_name IS NULL
                    OR substantive_level_of_service_stage IS NULL))
            OR (accepted_emergency_defaults = false
                AND (emergency_level_of_service IS NULL
                    OR emergency_level_of_service_name IS NULL
                    OR emergency_level_of_service_stage IS NULL))
        );
      SQL
    end
  end
end
