module Providers
  class OtherAssetsController < BaseController
    include ApplicationDependable
    include SaveAsDraftable

    def show
      @form = Citizens::OtherAssetsForm.new(model: declaration)
    end

    def update
      @form = Citizens::OtherAssetsForm.new(form_params)
      if @form.save
        continue_or_save_draft(continue_url: next_url)
      else
        render :show
      end
    end

    private

    def next_url
      if own_home? || savings_or_investments? || other_assets?
        providers_legal_aid_application_restrictions_path(legal_aid_application)
      else
        providers_legal_aid_application_check_provider_answers_path(legal_aid_application)
      end
    end

    def own_home?
      legal_aid_application.own_home?
    end

    def savings_or_investments?
      legal_aid_application.savings_or_investments?
    end

    def other_assets?
      legal_aid_application.other_assets?
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
