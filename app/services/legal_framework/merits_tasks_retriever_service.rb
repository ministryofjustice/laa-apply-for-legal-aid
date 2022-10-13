module LegalFramework
  class MeritsTasksRetrieverService < BaseService
    ENDPOINT = "/merits_tasks".freeze
    NEW_ENDPOINT = "/civil_merits_questions".freeze

    def url_path
      return NEW_ENDPOINT if Setting.enable_mini_loop?

      ENDPOINT
    end

    def request_body
      if Setting.enable_mini_loop?
        {
          request_id:,
          proceedings: proceedings_data,
        }.to_json
      else
        {
          request_id:,
          proceeding_types: proceeding_types_codes,
        }.to_json
      end
    end

  private

    def proceeding_types_codes
      legal_aid_application.proceedings.map(&:ccms_code)
    end

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
