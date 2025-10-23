module Providers
  module LinkApplication
    class ConfirmLinkForm < BaseForm
      form_for LinkedApplication

      attr_accessor :confirm_link

      validates :confirm_link, presence: true, unless: :draft?

      def save
        super
        if confirm_link == "No"
          model.update!(confirm_link: nil)
        elsif legal_linking? || confirm_link == "false"
          model.associated_application.update!(linked_application_completed: true)
        end
      end
      alias_method :save!, :save

    private

      def legal_linking?
        confirm_link == "true" && model.link_type_code.eql?("LEGAL")
      end
    end
  end
end
