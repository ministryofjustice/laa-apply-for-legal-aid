module Providers
  class UploadedEvidenceSubmissionForm < BaseFileUploaderForm
    form_for UploadedEvidenceCollection

    attr_accessor :provider_uploader

    validate :all_evidence_categorised
    validate :mandatory_evidence_uploaded

    def all_evidence_categorised
      return true unless uncategorised_evidence_exists

      errors.add(:uploaded_evidence_collection_select,
                 I18n.t("#{error_path}.uncategorised_evidence"))
    end

    def uncategorised_evidence_exists
      model.original_attachments.any? { |attachment| attachment.attachment_type == 'uncategorised' }
    end

    def mandatory_evidence_uploaded
      model.mandatory_evidence_types.each do |type|
        next if model.categorised_evidence_types.include?(type)

        errors.add("uploaded_evidence_collection_#{type}",
                   I18n.t("#{error_path}.#{type}_missing",
                          benefit: model.legal_aid_application.dwp_override.passporting_benefit.titleize))
      end
    end

    private

    def error_path
      '.activemodel.errors.models.uploaded_evidence_collection.attributes.original_file'
    end
  end
end
