module Providers
  module LinkApplication
    class ConfirmLinkForm < BaseForm
      form_for LegalAidApplication

      attr_accessor :link_case

      validates :link_case, presence: true, unless: :draft?

      def save
        if link_case == "No"
          model.update!(link_case: nil)
          return
        end
        super
      end
      alias_method :save!, :save
    end
  end
end
