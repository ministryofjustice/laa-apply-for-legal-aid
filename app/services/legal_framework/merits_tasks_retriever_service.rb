module LegalFramework
  class MeritsTasksRetrieverService < BaseService
    ENDPOINT = "/civil_merits_questions".freeze

    def url_path
      ENDPOINT
    end

    def request_body
      {
        request_id:,
        proceedings: proceedings_data,
      }.to_json
    end

  private

    def proceedings_data
      legal_aid_application.proceedings.map do |proceeding|
        {
          ccms_code: proceeding.ccms_code,
          delegated_functions_used: proceeding.used_delegated_functions,
          client_involvement_type: proceeding.client_involvement_type_ccms_code,
        }
      end
    end
  end
end
