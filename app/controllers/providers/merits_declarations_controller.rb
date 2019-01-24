module Providers
  class MeritsDeclarationsController < BaseController
    include ApplicationDependable
    include Steppable

    def show
      @form = MeritsAssessments::MeritsDeclarationForm.new(model: merits_assessment)
      # TODO add in  correct back_step_url should point to rpospects of success when it is created
      @back_step_url = providers_legal_aid_application_check_provider_answers_path
    end

    def update
      @form = MeritsAssessments::MeritsDeclarationForm.new(merits_declaration_params.merge(model: merits_assessment))

      @form.save
      # TO DO add correct redirect here
      # There is no alternate path for client not to declare/agree
      render plain: 'Testing update when form saved'

      # TODO __THIS MIGHT NOT BE NECESSARY--add in  correct back_step_url should point to rpospects of success when it is created
      # @back_step_url = providers_legal_aid_application_address_lookup_path
    end

    private

    def merits_assessment
      @merits_assessment ||= legal_aid_application.merits_assessment || legal_aid_application.build_merits_assessment
    end

    def merits_declaration_params
      params.permit(:client_merits_declaration)
    end
  end
end
