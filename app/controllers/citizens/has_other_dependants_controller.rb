module Citizens
  class HasOtherDependantsController < BaseController
    include ApplicationFromSession

    def show; end

    def update
      if params[:other_dependant].in?(%w[yes no])
        go_forward(params[:other_dependant] == 'yes')
      else
        @error = I18n.t('citizens.has_other_dependants.show.error')
        render :show
      end
    end
  end
end
