module Providers
  class TaskListsController < ApplicationController
    before_action :authenticate_provider!
    before_action :update_locale
    include Authorizable
    include ApplicationDependable

    def show
      legal_aid_application

      @task_list = ::TaskList::StartPageCollection.new(
        view_context, application: legal_aid_application
      )
    end

    def create
      legal_aid_application

      redirect_to providers_legal_aid_application_task_list_path(legal_aid_application.id)
    end

    def legal_aid_application
      @legal_aid_application ||=
        LegalAidApplication.find_by(id: task_list_params[:legal_aid_application_id]) || LegalAidApplication.create!(provider: current_provider, office: current_provider.selected_office)
    end

    def task_list_params
      params.permit(%i[legal_aid_application_id locale])
    end
  end
end
