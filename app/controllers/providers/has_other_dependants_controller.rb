module Providers
  class HasOtherDependantsController < ProviderBaseController
    def show; end

    def update
      if params[:other_dependant].in?(%w[true false])
        go_forward(params[:other_dependant] == 'true')
      else
        @error = { 'other_dependant-error' => I18n.t('providers.has_other_dependants.show.error') }
        render :show
      end
    end
  end
end
