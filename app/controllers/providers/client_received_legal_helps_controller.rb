module Providers
  class ClientReceivedLegalHelpsController < BaseController
    include ApplicationDependable
    include Steppable
    include SaveAsDraftable

    def show
      @form = MeritsAssessments::ClientReceivedLegalHelpForm.new(model: merits_assessment)
    end

    def update
      @form = MeritsAssessments::ClientReceivedLegalHelpForm.new(client_received_legal_help_params.merge(model: merits_assessment))

      if @form.save
        # TODO: remove this condition once next step is implemented
        if params.key?(:continue_button)
          render plain: 'Placeholder: Are the proceedings, for which funding is being sought, currently, before the court?'
          return
        end
        continue_or_save_draft
      else
        render :show
      end
    end

    private

    def merits_assessment
      @merits_assessment ||= legal_aid_application.merits_assessment || legal_aid_application.build_merits_assessment
    end

    def client_received_legal_help_params
      params.require(:merits_assessment).permit(:client_received_legal_help, :application_purpose)
    end
  end
end
