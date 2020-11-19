module Providers
  class RemoveDependantController < ProviderBaseController
    def show
      @dependant = dependant
    end

    def update
      if params[:remove_dependant].in?(%w[true false])
        dependant&.destroy! if params[:remove_dependant] == 'true'
        go_forward
      else
        @error = { 'remove_dependants-error' => I18n.t('providers.remove_dependant.show.error') }
        @dependant = dependant
        render :show
      end
    end

    private

    def dependant
      @legal_aid_application.dependants.find(params[:id])
    end
  end
end
