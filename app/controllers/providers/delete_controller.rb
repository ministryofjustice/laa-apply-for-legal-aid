module Providers
  class DeleteController < ProviderBaseController
    def show
      redirect_to providers_legal_aid_applications_path if @legal_aid_application.discarded?
    end

    def destroy
      @legal_aid_application.discard
      @legal_aid_application.scheduled_mailings.map(&:cancel!)
      flash[:hash] = {
        title_text: t("generic.success"),
        success: true,
        heading_text: t("providers.legal_aid_applications.destroy"),
      }
      redirect_to providers_legal_aid_applications_path
    end
  end
end
