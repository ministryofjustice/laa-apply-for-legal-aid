module Providers
  module Means
    module CapitalDisregards
      class DiscretionaryController < ProviderBaseController
        prefix_step_with :capital_disregards

        def show
          @form = DiscretionaryForm.new(model: legal_aid_application)
        end

        def update
          @form = DiscretionaryForm.new(form_params)
          return continue_or_draft if draft_selected?

          if @form.valid?
            @form.save!
            go_forward(@legal_aid_application.next_incomplete_discretionary_disregard)
          else
            render :show
          end
        end

      private

        def form_params
          params
            .require(:providers_means_capital_disregards_discretionary_form)
            .permit(:none_selected, discretionary_capital_disregards: [])
            .merge(legal_aid_application:)
        end
      end
    end
  end
end
