module TaskStatus
  module Validators
    class MakeLink < Base

      def valid?
        return true if linked_application.confirm_link == false

        super
      end

      def forms
        relevant_forms = [make_link_form]

        relevant_forms << confirm_link_form unless linked_application.link_type_code == "false"
        relevant_forms << copy_form if linked_application.link_type_code == "FC_LEAD"

        relevant_forms
      end

      def make_link_form
        @make_link_form ||= ::Providers::LinkApplication::MakeLinkForm.new(model: linked_application)
      end

      def confirm_link_form
        @confirm_link_form ||= ::Providers::LinkApplication::ConfirmLinkForm.new(model: linked_application)
      end

      def copy_form
        @copy_form ||= ::Providers::LinkApplication::CopyForm.new(model: linked_application)
      end

      def linked_application
        application.lead_linked_application || application.build_lead_linked_application
      end
    end
  end
end
