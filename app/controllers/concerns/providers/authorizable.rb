# If included in a controller this will enable pundit and make `authorize legal_aid_application` the default behaviour
# Controllers that have `legal_aid_application_not_required!` will also not use the default behaviour set here.
# Relies on `legal_aid_application` method being available - so define after `ApplicationDependable`.
module Providers
  module Authorizable
    extend ActiveSupport::Concern

    class_methods do
      attr_reader :authorize_with_policy_method_name

      # Use this class method in a controller to set the policy to be used within that controller
      # If not set the policy will behave as normal for Pundit (policy will be based on action name)
      def authorize_with_policy_method(name)
        @authorize_with_policy_method_name = name
      end
    end

    included do
      include Pundit::Authorization

      before_action :authorize_portal_user?
      before_action :authorize_legal_aid_application
      rescue_from Pundit::NotAuthorizedError, with: :provider_not_authorized

      def pundit_user
        AuthorizationContext.new(current_provider, self)
      end

    private

      def provider_not_authorized
        respond_to do |format|
          format.html do
            if current_policy.show_submitted_application?
              redirect_to_show_path
            else
              redirect_to error_path(:access_denied)
            end
          end
        end
      end

      def redirect_to_show_path
        redirect_to providers_legal_aid_application_submitted_application_path(legal_aid_application)
      end

      def current_policy
        Pundit.policy pundit_user, legal_aid_application
      end

      def authorize_portal_user?
        return false if current_provider.portal_enabled?

        redirect_to error_path(:access_denied)
      end

      def authorize_legal_aid_application
        return if self.class.legal_aid_application_not_required?
        return unless legal_aid_application # let missing application through so can be caught as not found

        authorize legal_aid_application, self.class.authorize_with_policy_method_name
      end
    end
  end
end
