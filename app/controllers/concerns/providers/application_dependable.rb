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
        return process_invalid_application unless legal_aid_application.present?

        legal_aid_application.update!(provider_step: controller_name)
      end

      def process_invalid_application
        flash[:error] = 'Invalid application'
        redirect_to providers_legal_aid_applications_path
      end
    end
  end
end
