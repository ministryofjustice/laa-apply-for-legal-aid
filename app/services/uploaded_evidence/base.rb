module UploadedEvidence
  class Base
    delegate :legal_aid_application,
             :params,
             to: :controller

    attr_reader :controller, :successful_upload, :error_message, :successfully_deleted, :next_action

    def self.call(controller)
      new(controller).call
    end

    def initialize(controller)
      @controller = controller
    end

    def call
      klass = if upload_button_pressed?
                UploaderService
              elsif draft_button_pressed?
                DraftService
              elsif delete_button_pressed?
                DeletionService
              elsif save_and_continue_button_pressed?
                SaveAndContinueService
              end
      klass.call(controller)
    end

    def attachment_type_options
      @attachment_type_options = required_documents.map { |rd| [rd, rd.humanize] }
      @attachment_type_options << %w[uncategorised Uncategorised]
      @attachment_type_options
    end

    def evidence_type_translation
      return unless required_documents.include?("benefit_evidence")

      I18n.t(".shared.forms.received_benefit_confirmation.form.providers.received_benefit_confirmations.#{passporting_benefit}")
    end

    def mandatory_evidence_errors
      uploaded_evidence_collection.errors.errors.select { |error| error.options[:mandatory_evidence] }
    end

    def categorisation_errors
      uploaded_evidence_collection.errors.errors.reject { |error| error.options[:mandatory_evidence] }
    end

    def upload_form
      @upload_form ||= Providers::UploadedEvidenceCollectionForm.new(uploaded_evidence_collection_params)
    end

    def required_documents
      @required_documents = legal_aid_application.required_document_categories
    end

    def submission_form
      @submission_form ||= Providers::UploadedEvidenceSubmissionForm.new(uploaded_evidence_collection_params)
    end

    def populate_upload_form
      required_documents
      @upload_form = Providers::UploadedEvidenceCollectionForm.new(model: uploaded_evidence_collection)
      attachment_type_options
      evidence_type_translation
      mandatory_evidence_errors
      categorisation_errors
    end

    def uploaded_evidence_collection
      @uploaded_evidence_collection ||= legal_aid_application.uploaded_evidence_collection || legal_aid_application.build_uploaded_evidence_collection
    end

  private

    def params
      @controller.__send__(:params)
    end

    def upload_button_pressed?
      params[:upload_button].present?
    end

    def draft_button_pressed?
      params[:draft_button].present?
    end

    def delete_button_pressed?
      params[:delete_button].present?
    end

    def save_and_continue_button_pressed?
      params[:continue_button].present?
    end

    def passporting_benefit
      legal_aid_application.dwp_override.passporting_benefit
    end

    def populate_submission_form
      @submission_form = Providers::UploadedEvidenceSubmissionForm.new(model: uploaded_evidence_collection)
    end

    def update_attachment_type
      params[:uploaded_evidence_collection].each do |att_id, new_att_type|
        Attachment.find(att_id).update(attachment_type: new_att_type)
      end
    end

    def uploaded_evidence_collection_params
      params[:uploaded_evidence_collection] = { original_file: [] } unless params.key?(:uploaded_evidence_collection)
      @controller.merge_with_model(uploaded_evidence_collection, provider_uploader: @controller.current_provider) do
        params.require(:uploaded_evidence_collection).permit(:original_file)
      end
    end
  end
end
