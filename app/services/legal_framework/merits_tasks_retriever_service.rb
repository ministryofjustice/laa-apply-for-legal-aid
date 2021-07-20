module LegalFramework
  class MeritsTasksRetrieverService < BaseService
    ENDPOINT = '/merits_tasks'.freeze

    def url_path
      ENDPOINT
    end

    def request_body
      {
        request_id: request_id,
        proceeding_types: proceeding_types_codes
      }.to_json
    end

    private

    def proceeding_types_codes
      legal_aid_application.application_proceeding_types.map{ |apt| apt.proceeding_type.ccms_code }
    end
  end
end
