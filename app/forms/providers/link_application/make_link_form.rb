module Providers
  module LinkApplication
    class MakeLinkForm < BaseForm
      form_for LinkedApplication

      attr_accessor :link_type_code

      validates :link_type_code, presence: true, unless: :draft?

      def save
        model.update!(confirm_link: link_type_code == "false" ? false : nil)
        if link_type_code.eql?("LEGAL")
          model.associated_application.update!(copy_case: nil, copy_case_id: nil)
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
