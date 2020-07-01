module Providers
  class HasOtherDependantsController < ProviderBaseController
    def show; end

    def update
      if params[:other_dependant].in?(%w[yes no])
        go_forward(params[:other_dependant] == 'yes')
      else
        @error = I18n.t('providers.has_other_dependants.show.error')
        render :show
      end
    end

    def destroy
      dependant&.destroy!
      redirect_to providers_legal_aid_application_has_other_dependants_path
    end

    private

    def dependant
      @legal_aid_application.dependants.find(params[:dependant_id])
    end
  end
end
