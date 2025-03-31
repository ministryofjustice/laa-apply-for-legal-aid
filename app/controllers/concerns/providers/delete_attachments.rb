module Providers
  module DeleteAttachments
  private

    def find_attachments_starting_with(text)
      legal_aid_application.attachments.find_all { |attachment| attachment[:attachment_type].start_with?(text) }
    end

    def delete_evidence(array)
      array.each do |attachment|
        attachment.document.purge_later
        attachment.destroy!
      end
    end
  end
end
