module Providers
  class GatewayEvidenceForm < BaseFileUploaderForm
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
  end
end
