module Providers
  class GatewayEvidenceForm
    include BaseForm
    include BaseFileUploaderForm

    form_for GatewayEvidence

    attr_accessor :original_file, :provider_uploader, :upload_button_pressed

    validate :original_file_valid
    validate :file_uploaded?

    def save
      return if original_file.nil?

      model.save(validate: false) if attachments_made?
    end

    def files?
      original_file.present?
    end

    private

    def too_big(original_file)
      return if original_file_size(original_file) <= GatewayEvidenceForm.max_file_size

      error_options = { size: GatewayEvidenceForm.max_file_size / 1.megabyte, file_name: @original_filename }
      errors.add(:original_file, original_file_error_for(:file_too_big, error_options))
    end

    def original_file_error_for(error_type, options = {})
      I18n.t("activemodel.errors.models.gateway_evidence.attributes.original_file.#{error_type}", **options)
    end

    def create_attachment(original_file)
      model.legal_aid_application.attachments.create document: original_file, attachment_type: 'gateway_evidence', original_filename: @original_file.original_filename,
                                                     attachment_name: sequenced_attachment_name
    end

    def sequenced_attachment_name
      if model.original_attachments.any?
        most_recent_name = model.original_attachments.order(:attachment_name).last.attachment_name
        increment_name(most_recent_name)
      else
        'gateway_evidence'
      end
    end

    def increment_name(most_recent_name)
      if most_recent_name == 'gateway_evidence'
        'gateway_evidence_1'
      else
        most_recent_name =~ /^gateway_evidence_(\d+)$/
        "gateway_evidence_#{Regexp.last_match(1).to_i + 1}"
      end
    end
  end
end
