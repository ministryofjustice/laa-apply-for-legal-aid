module Providers
  class SessionsController < Devise::SessionsController
    def destroy
      flash[:notice] = t("devise.sessions.destroy.notice")
      session["signed_out"] = true
      session["feedback_return_path"] = destroy_provider_session_path
      super
    end

  protected

    def after_sign_out_path_for(_resource_or_scope)
      new_feedback_path
    end
  end
end
