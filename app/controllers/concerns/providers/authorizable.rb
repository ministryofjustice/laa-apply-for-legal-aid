# Relies on `legal_aid_application` method being available - so define after `ApplicationDependable`
module Providers
  module Authorizable
    extend ActiveSupport::Concern

    class_methods do
      def use_custom_authorization!
        @use_custom_authorization = true
      end

      def use_custom_authorization?
        @use_custom_authorization
      end
    end

    included do
      before_action :authorize_legal_aid_application
      rescue_from Pundit::NotAuthorizedError, with: :provider_not_authorized

      def pundit_user
        current_provider
      end

      private

      def provider_not_authorized
        respond_to do |format|
          format.html do
            if current_policy.show_submitted_application?
              redirect_to(
                providers_legal_aid_application_submitted_application_path(legal_aid_application),
                notice: 'Update denied: redirecting to submitted application'
              )
            else
              redirect_to error_path(:access_denied)
            end
          end
        end
      end

      def current_policy
        Pundit.policy pundit_user, legal_aid_application
      end

      def authorize_legal_aid_application
        return if self.class.use_custom_authorization?
        return unless legal_aid_application

        authorize legal_aid_application
      end
    end
  end
end
