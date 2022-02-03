module V1
  class StatementOfCasesController < ApiController
    ATTACHMENT_TYPE = 'statement_of_case'.freeze

    def create
      return head :not_found unless legal_aid_application

      file = form_params[:file]

      malware_scan = malware_scan_result(file)
      return render json: { error: original_file_error_for(:file_virus) }, status: :bad_request if malware_scan.virus_found?
      return render json: { error: original_file_error_for(:system_down) }, status: :bad_request unless malware_scan.scanner_working

      legal_aid_application.attachments.create document: file,
                                               attachment_type: ATTACHMENT_TYPE,
                                               original_filename: file.original_filename,
                                               attachment_name: sequenced_attachment_name
      head :ok
    end

    private

    def provider_uploader
      legal_aid_application.provider
    end

    def malware_scan_result(original_file)
      MalwareScanner.call(
        file_path: original_file.tempfile.path,
        uploader: provider_uploader,
        file_details: {
          size: original_file_size(original_file),
          name: original_file.original_filename,
          content_type: original_file.content_type
        }
      )
    end

    def original_file_size(original_file)
      File.size(original_file.tempfile)
    end

    def original_file_error_for(error_type, options = {})
      I18n.t("activemodel.errors.models.#{error_path}.attributes.original_file.#{error_type}", **options)
    end

    def error_path
      'application_merits_task/statement_of_case'
    end

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find_by(id: form_params[:legal_aid_application_id])
    end

    def form_params
      params.permit(%i[legal_aid_application_id file])
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
