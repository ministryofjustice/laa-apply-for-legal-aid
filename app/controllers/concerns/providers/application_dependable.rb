module Providers
  module ApplicationDependable
    extend ActiveSupport::Concern

    included do
      before_action :set_legal_aid_application

      def legal_aid_application
        @legal_aid_application ||= LegalAidApplication.find_by(id: params[:legal_aid_application_id])
      end

      def set_legal_aid_application
        return if legal_aid_application.present?

        # TODO: Wording might need to be changed
        flash[:error] = 'Invalid application'
        redirect_to providers_legal_aid_applications_path
      end
    end
  end
end
