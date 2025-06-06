module Providers
  class DeleteController < ProviderBaseController
    def show
      @scope = :delete
      set_redirect_url

      redirect_to home_path if @legal_aid_application.discarded?
    end

    def destroy
      @legal_aid_application.discard
      @legal_aid_application.scheduled_mailings.map(&:cancel!)
      flash[:hash] = {
        title_text: t("generic.success"),
        success: true,
        heading_text: t("providers.legal_aid_applications.destroy"),
      }

      redirect_to_page_before_last
    end

  private

    # TODO: 15 OCT 2024 @agoldstone93
    # Consider adding the methods below to the Backable concern
    def set_redirect_url
      session[:previous_url] = request.referer
    end

    def redirect_to_page_before_last
      session[:previous_url].present? ? redirect_to(session[:previous_url]) : redirect_to(home_path)
    end
  end
end
