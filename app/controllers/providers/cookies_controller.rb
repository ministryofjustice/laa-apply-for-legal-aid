module Providers
  class CookiesController < ProviderBaseController
    legal_aid_application_not_required!

    def show
      @form = Providers::CookiesForm.new(model: current_provider)
    end

    def update
      @form = Providers::CookiesForm.new(form_params)
      if @form.save
        @successfully_saved = true
      end
      render :show
    end

  private

    def form_params
      merge_with_model(current_provider) do
        next {} unless params[:provider]

        params.expect(provider: [:cookies_enabled])
      end
    end
  end
end
