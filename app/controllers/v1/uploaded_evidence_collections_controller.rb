module V1
  class UploadedEvidenceCollectionsController < ApiController
    include MalwareScanning

    def create
      return head :not_found unless legal_aid_application

      file = form_params[:file]
      malware_scan = malware_scan_result(file)

      return render json: { error: original_file_error_for(:file_virus, file_name: file.original_filename) }, status: :bad_request if malware_scan.virus_found?
      return render json: { error: original_file_error_for(:system_down) }, status: :bad_request unless malware_scan.scanner_working

      legal_aid_application.attachments.create! document: file,
                                                attachment_type: "uncategorised",
                                                original_filename: file.original_filename,
                                                attachment_name: sequenced_attachment_name
      head :ok
    end

  private

    def model
      @model ||= legal_aid_application.uploaded_evidence_collection || legal_aid_application.build_uploaded_evidence_collection
    end

    def name
      @name ||= @model.class.name.demodulize.underscore
    end

    def legal_aid_application
      return @legal_aid_application if defined?(@legal_aid_application)

      @legal_aid_application = LegalAidApplication.find_by(id: form_params[:legal_aid_application_id])
    end

    def form_params
      params.permit(%i[legal_aid_application_id file])
    end

    def sequenced_attachment_name
      if model.original_attachments.any?
        most_recent_name = model.original_attachments.order(:attachment_name).last.attachment_name
        increment_name(most_recent_name)
      else
        name
      end
    end

    def increment_name(most_recent_name)
      return "#{name}_1" if most_recent_name == name

      # NOTE: silence Vulnerability scanner, snyk, false positive over ReDOS attack vector.
      # The scanner thinks name value could be user input, but it is not. It is a
      # hardcoded string based on the model name.
      escaped_name = Regexp.escape(name)

      match = most_recent_name.match(/\A#{escaped_name}_(\d+)\z/)

      return "#{name}_1" unless match

      "#{name}_#{match[1].to_i + 1}"
    end

    def provider_uploader
      legal_aid_application.provider
    end

    def error_path
      "uploaded_evidence_collection"
    end
  end
end
