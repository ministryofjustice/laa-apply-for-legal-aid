module Providers
  module ApplicationDependable
    extend ActiveSupport::Concern

    class_methods do
      def legal_aid_application_not_required!
        @legal_aid_application_not_required = true
      end

      def legal_aid_application_not_required?
        @legal_aid_application_not_required
      end
    end

    included do
      before_action :set_legal_aid_application

      def legal_aid_application
        @legal_aid_application ||= LegalAidApplication.find_by(id: params[:legal_aid_application_id])
      end
      delegate :applicant, to: :legal_aid_application

      private

      def set_legal_aid_application
        return if self.class.legal_aid_application_not_required?
        return process_invalid_application if legal_aid_application.blank?

        legal_aid_application.update!(provider_step: provider_step, provider_step_params: provider_step_params) unless provider_step == :delete
      end

      def process_invalid_application
        redirect_to error_path(:page_not_found)
      end

      def provider_step_params
        params.except(:action, :controller, :legal_aid_application_id)
      end

      def provider_step
        respond_to?(:current_step) ? __send__(:current_step) : controller_name
      end
    end
  end
end
