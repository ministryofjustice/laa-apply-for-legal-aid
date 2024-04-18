module Providers
  module LinkApplication
    class MakeLinkForm < BaseForm
      form_for LinkedApplication

      attr_accessor :link_type_code

      validates :link_type_code, presence: true, unless: :draft?

      def save
        if link_type_code == "false"
          model.destroy!
          return
        end
        super
      end
      alias_method :save!, :save

      def self.family_link_type_code
        @family_link_type_code ||= LinkedApplicationType.all.find { |linked_application_type| linked_application_type.description == "Family" }.code
      end

      def self.legal_link_type_code
        @legal_link_type_code ||= LinkedApplicationType.all.find { |linked_application_type| linked_application_type.description == "Legal" }.code
      end
    end
  end
end
