module V1
  class BankStatementsController < ApiController
    include MalwareScanning

    def initialize
      super
      @attachment_type = "bank_statement_evidence"
      @attachment_type_capture = /^#{@attachment_type}_(\d+)$/
    end

    def create
      return head :not_found unless legal_aid_application

      file = form_params[:file]

      malware_scan = malware_scan_result(file)
      return render json: { error: original_file_error_for(:file_virus, file_name: file.original_filename) }, status: :bad_request if malware_scan.virus_found?
      return render json: { error: original_file_error_for(:system_down) }, status: :bad_request unless malware_scan.scanner_working

      attachment = legal_aid_application
                     .attachments
                     .create!(document: file,
                              attachment_type: @attachment_type,
                              original_filename: file.original_filename,
                              attachment_name: sequenced_attachment_name)

      PdfConverterWorker.perform_async(attachment.id)

      head :ok
    end

  private

    def provider_uploader
      legal_aid_application.provider
    end

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find_by(id: form_params[:legal_aid_application_id])
    end

    def form_params
      params.permit(%i[legal_aid_application_id file])
    end

    # can be shared with v1 bank statement controller
    def sequenced_attachment_name
      if legal_aid_application.attachments.bank_statement_evidence.any?
        most_recent_name = legal_aid_application.attachments.bank_statement_evidence.order(:attachment_name).last.attachment_name
        increment_name(most_recent_name)
      else
        @attachment_type
      end
    end

    def increment_name(most_recent_name)
      if most_recent_name == @attachment_type
        "#{@attachment_type}_1"
      else
        most_recent_name =~ @attachment_type_capture
        "#{@attachment_type}_#{Regexp.last_match(1).to_i + 1}"
      end
    end

    def error_path
      "providers/bank_statement_form"
    end
  end
end
