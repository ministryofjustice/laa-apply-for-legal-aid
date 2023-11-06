module Providers
  class LinkingCaseSearchesController < ProviderBaseController
    def show
      @form = LinkingCase::SearchForm.new(model: legal_aid_application)
    end

    def update
      @form = LinkingCase::SearchForm.new(form_params)

      render :show unless save_continue_or_draft(@form)
    end

  private

    def save_continue_or_draft(form, **)
      draft_selected? ? form.save_as_draft : form.save!
      return false if form.invalid?

      session[:link_case_id] = form.linkable_case.id
      continue_or_draft(**)
    end

    def form_params
      merge_with_model(legal_aid_application) do
        params.require(:legal_aid_application).permit(:search_ref)
      end
    end
  end
end
