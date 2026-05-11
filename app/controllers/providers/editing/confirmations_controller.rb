module Providers
  module Editing
    class ConfirmationsController < ProviderBaseController
      def show
        return_to_section
        sections_to_be_deleted
      end

      def destroy
        reset_to_section
        redirect_to reset_to_section_path, notice: I18n.t("providers.editing.confirmations.destroy.success")
      end

    private

      def sections_to_be_deleted
        @sections_to_be_deleted ||= sections_after(return_to_section)

        # Only show sections that have been started
        if @sections_to_be_deleted.any?
          @sections_to_be_deleted = @sections_to_be_deleted.select do |section|
            @legal_aid_application.editing_section_started?(section)
          end
        end

        @sections_to_be_deleted
      end

      def return_to_section
        @return_to_section ||= sanitised_params[:return_to_section]
      end

      def sanitised_params
        params.permit(:legal_aid_application_id, :return_to_section)
      end

      def reset_to_section
        ::Editing::Cleaner.new(@legal_aid_application, return_to_section).call
      end

      def reset_to_section_path
        @reset_to_section_path ||= sections.fetch(return_to_section.to_sym, nil)
      end

      def sections_after(section)
        i = sections.keys.index(section.to_sym)
        return [] unless i

        sections.keys[(i + 1)..] || []
      end

      # OPTIMISE: Can this be refactored to use a centralised location. Note, this will cause several issues due to the use of url helpers. See cleaner for its other use.
      def sections
        @sections ||=
          {
            client_details: providers_legal_aid_application_check_provider_answers_path,
            financial_assessment: providers_legal_aid_application_means_check_income_answers_path,
            capital_and_assets: legal_aid_application.passported? ? providers_legal_aid_application_check_passported_answers_path : providers_legal_aid_application_check_capital_answers_path,
            merits: providers_legal_aid_application_check_merits_answers_path, # TODO: remove, should not be used as designs say to go back directly to check merits answers page
          }
      end
    end
  end
end
