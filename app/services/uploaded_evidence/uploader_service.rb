module UploadedEvidence
  class UploaderService < Base
    def call
      upload_form.upload_button_pressed = true
      if upload_form.valid? && upload_form.save
        @successful_upload = successful_upload
      else
        @error_message = error_message
      end

      DocumentCategoryAnalyser.call(legal_aid_application)
      allowed_documents
      attachment_type_options

      @next_action = :show

      self
    end

    def submission_form
      nil
    end
  end
end
