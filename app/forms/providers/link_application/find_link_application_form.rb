module Providers
  module LinkApplication
    class FindLinkApplicationForm < BaseForm
      form_for LinkedApplication

      APPLICATION_REF_REGEXP = /\AL-[0-9ABCDEFHJKLMNPRTUVWXY]{3}-[0-9ABCDEFHJKLMNPRTUVWXY]{3}\z/i

      attr_accessor :search_laa_reference

      validates :search_laa_reference, presence: true, unless: :draft?

      def application_can_be_linked?
        return :missing_message unless search_laa_reference.match(APPLICATION_REF_REGEXP)

        current_firm = @model.associated_application.provider.firm
        @found_application = current_firm.legal_aid_applications.find_by(application_ref: search_laa_reference)
        return :missing_message if @found_application.blank?

        if @found_application.merits_submitted_at.present?
          true
        else
          :not_submitted_message
        end
      end

      def exclude_from_model
        [:search_laa_reference]
      end

      def save
        attributes[:lead_application_id] = @found_application.id
        super
      end
    end
  end
end
