module V1
  class UploadedEvidenceCollectionsController < ApiController
    def create
      if legal_aid_application
        file = form_params[:file]
        legal_aid_application.attachments.create document: file,
                                                 attachment_type: 'uncategorised',
                                                 original_filename: file.original_filename,
                                                 attachment_name: sequenced_attachment_name
        render '', status: :ok
      else
        render '', status: :not_found
      end
    end

    private

    def model
      @model ||= legal_aid_application.uploaded_evidence_collection || legal_aid_application.build_uploaded_evidence_collection
    end

    def name
      @name ||= @model.class.name.demodulize.underscore
    end

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find_by(id: form_params[:legal_aid_application_id])
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
      if most_recent_name == name
        "#{name}_1"
      else
        most_recent_name =~ /^#{name}_(\d+)$/
        "#{name}_#{Regexp.last_match(1).to_i + 1}"
      end
    end
  end
end
