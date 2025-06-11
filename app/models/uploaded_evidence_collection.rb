class UploadedEvidenceCollection < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :provider_uploader, class_name: "Provider", optional: true

  validate :all_evidence_categorised
  validate :all_mandatory_evidence_uploaded

  def original_attachments
    legal_aid_application.attachments.displayable_evidence_types
  end

private

  def all_evidence_categorised
    return unless uncategorised_evidence_exists?

    errors.add(:"uploaded-files-table-container", I18n.t("#{error_path}.uncategorised_evidence"), mandatory_evidence: false)
  end

  def uncategorised_evidence_exists?
    original_attachments.any? { |attachment| attachment.attachment_type == "uncategorised" }
  end

  def all_mandatory_evidence_uploaded
    mandatory_evidence_types.each do |type|
      next if categorised_evidence_types.include?(type)

      # link the error message to the dropzone
      errors.add("dz-upload-button", I18n.t("#{error_path}.#{type}_missing", benefit: passporting_benefit_title), mandatory_evidence: true)
    end

    mandatory_evidence_types.all? { |mandatory_type| categorised_evidence_types.include?(mandatory_type) }
  end

  def mandatory_evidence_types
    DocumentCategory.where(name: application_evidence_types, mandatory: true).pluck(:name)
  end

  def application_evidence_types
    legal_aid_application.allowed_document_categories
  end

  def categorised_evidence_types
    original_attachments.pluck(:attachment_type).uniq
  end

  def passporting_benefit_title
    legal_aid_application&.dwp_override&.passporting_benefit&.titleize
  end

  def error_path
    ".activemodel.errors.models.uploaded_evidence_collection.attributes.original_file"
  end
end
