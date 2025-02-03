module Providers
  class UploadedEvidenceCollectionsController < ProviderBaseController
    def show
      DocumentCategoryAnalyser.call(legal_aid_application)
      @service = UploadedEvidence::PopulateUploadFormService.call(self)
      copy_instance_variables
    end

    def update
      @service = UploadedEvidence::Base.call(self)
      copy_instance_variables

      case @service.next_action
      when :show
        render :show
      when :continue_or_draft
        continue_or_draft
      when :save_continue_or_draft
        save_continue_or_draft(@service.submission_form)
      end
    end

    def list
      DocumentCategoryAnalyser.call(legal_aid_application)
      @service = UploadedEvidence::ListService.call(self)
      @required_documents = @service.required_documents
      @attachment_type_options = @service.attachment_type_options
      @uploaded_evidence_collection = @service.uploaded_evidence_collection
      render partial: "uploaded_files", locals: { attachments: @service.uploaded_evidence_collection.original_attachments }
    end

  private

    def copy_instance_variables
      @attachment_type_options = @service.attachment_type_options
      @categorisation_errors = @service.categorisation_errors
      @error_message = @service.error_message
      @evidence_type_translation = @service.evidence_type_translation
      @mandatory_evidence_errors = @service.mandatory_evidence_errors
      @required_documents = @service.required_documents
      @submission_form = @service.submission_form
      @successful_upload = @service.successful_upload
      @successfully_deleted = @service.successfully_deleted
      @upload_form = @service.upload_form
      @uploaded_evidence_collection = @service.uploaded_evidence_collection
    end
  end
end
