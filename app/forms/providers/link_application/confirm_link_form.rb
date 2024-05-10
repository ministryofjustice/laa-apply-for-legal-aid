module Providers
  module LinkApplication
    class ConfirmLinkForm < BaseForm
      form_for LinkedApplication

      attr_accessor :confirm_link

      validates :confirm_link, presence: true, unless: :draft?

      def save
        super
        model.update!(confirm_link: nil) if confirm_link == "No"
      end
      alias_method :save!, :save
    end
  end
end
