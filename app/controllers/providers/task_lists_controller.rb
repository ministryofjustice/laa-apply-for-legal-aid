module Providers
  class TaskListsController < ApplicationController
    before_action :authenticate_provider!
    before_action :update_locale
    include Authorizable
    include ApplicationDependable

    def create
      @tasklist = TaskList::StartPageCollection.new(
        view_context, application: legal_aid_application
      )

      render :show
    end

    def legal_aid_application
      @legal_aid_application ||=
        LegalAidApplication.find_by(id: params[:legal_aid_application_id]) || LegalAidApplication.create!(provider: current_provider, office: current_provider.selected_office)
    end

    # def application_task_list_params
    #   params.expect(legal_aid_application: [:id])
    # end
  end
end
