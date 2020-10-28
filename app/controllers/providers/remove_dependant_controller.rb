module Providers
  class RemoveDependantController < ProviderBaseController
    def show
      @dependant = dependant
    end

    def update
      if params[:remove_dependant].in?(%w[yes no])
        dependant&.destroy! if params[:remove_dependant] == 'yes'
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
  end./spec/requests/providers/outgoings_summary_spec.rb:140:
end
