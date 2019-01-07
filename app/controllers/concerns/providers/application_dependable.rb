module Providers
  module ApplicationDependable
    extend ActiveSupport::Concern

    included do
      before_action :set_legal_aid_application

      def legal_aid_application
        @legal_aid_application ||= LegalAidApplication.find_by(id: params[:legal_aid_application_id])
      end
      delegate :applicant, to: :legal_aid_application

      private

      def set_legal_aid_application
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
