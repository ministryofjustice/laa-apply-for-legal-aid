module Providers
  class CopyCaseSearchesController < ProviderBaseController
    def show
      @form = CopyCase::SearchForm.new(model: legal_aid_application)
    end

    def update
      @form = CopyCase::SearchForm.new(form_params)

      render :show unless save_continue_or_draft(@form)
    end

  private

    def save_continue_or_draft(form, **)
      draft_selected? ? form.save_as_draft : form.save!
      return false if form.invalid?

      session[:copy_case_id] = form.copiable_case.id
      continue_or_draft(**)
    end

    def form_params
      params.require(:legal_aid_application).permit(:search_ref)
    end
  end
end
