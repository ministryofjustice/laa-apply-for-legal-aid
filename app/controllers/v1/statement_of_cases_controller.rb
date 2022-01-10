module V1
  class StatementOfCasesController < ApiController
    ATTACHMENT_TYPE = 'statement_of_case'.freeze

    def create
      legal_aid_application.attachments.create document: form_params[:file],
                                               attachment_type: ATTACHMENT_TYPE,
                                               original_filename: form_params[:original_filename],
                                               attachment_name: sequenced_attachment_name
    end

    private

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find_by(id: form_params[:legal_aid_application_id])
    end

    def form_params
      params.permit(%i[legal_aid_application_id file original_filename])
    end

    def sequenced_attachment_name
      if legal_aid_application.attachments.statement_of_case.any?
        most_recent_name = legal_aid_application.attachments.statement_of_case.order(:attachment_name).last.attachment_name
        increment_name(most_recent_name)
      else
        ATTACHMENT_TYPE
      end
    end

    def increment_name(most_recent_name)
      name = ATTACHMENT_TYPE
      if most_recent_name == name
        "#{name}_1"
      else
        most_recent_name =~ /^#{name}_(\d+)$/
        "#{name}_#{Regexp.last_match(1).to_i + 1}"
      end
    end
  end
end
