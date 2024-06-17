module Providers
  module LinkApplication
    class FindLinkApplicationForm < BaseForm
      form_for LinkedApplication

      APPLICATION_REF_REGEXP = /\AL-[0-9ABCDEFHJKLMNPRTUVWXY]{3}-[0-9ABCDEFHJKLMNPRTUVWXY]{3}\z/i

      attr_accessor :search_laa_reference, :legal_aid_application

      validates :search_laa_reference, presence: true, unless: :draft?

      def initialize(*args)
        super
        @legal_aid_application = model.associated_application
      end

      def application_can_be_linked?
        return :missing_message unless normalised_laa_reference.match(APPLICATION_REF_REGEXP)

        current_firm = @model.associated_application.provider.firm
        @found_application = current_firm.legal_aid_applications.find_by(application_ref: normalised_laa_reference)
        return :missing_message if @found_application.blank?
        return :voided_or_deleted_message if @found_application.discarded? || @found_application.expired?

        if @found_application.merits_submitted_at.present?
          true
        else
          :not_submitted_message
        end
      end

      def exclude_from_model
        %i[search_laa_reference legal_aid_application]
      end

      def save
        attributes[:lead_application_id] = @found_application&.id
        super
      end
      alias_method :save!, :save

    private

      def normalised_laa_reference
        @normalised_laa_reference ||= search_laa_reference.upcase.gsub(/[^0-9a-z\\s]/i, "").insert(1, "-").insert(5, "-")
      end
    end
  end
end
