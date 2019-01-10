module Providers
  class OtherAssetsController < BaseController
    include ApplicationDependable
    include SaveAsDraftable
    include Steppable

    def show
      authorize @legal_aid_application
      @form = Citizens::OtherAssetsForm.new(model: declaration)
    end

    def update
      authorize @legal_aid_application
      @form = Citizens::OtherAssetsForm.new(form_params)
      if @form.save
        continue_or_save_draft(continue_url: next_url)
      else
        render :show
      end
    end

    private

    def next_url
      if legal_aid_application.own_capital?
        providers_legal_aid_application_restrictions_path(legal_aid_application)
      else
        providers_legal_aid_application_check_provider_answers_path(legal_aid_application)
      end
    end

    def declaration
      @declaration ||= legal_aid_application.other_assets_declaration
    end

    def other_asset_params
      params[:other_assets_declaration].permit(*(Citizens::OtherAssetsForm::ALL_ATTRIBUTES + Citizens::OtherAssetsForm::CHECK_BOXES_ATTRIBUTES))
    end

    def form_params
      other_asset_params.merge(model: declaration)
    end
  end
end
