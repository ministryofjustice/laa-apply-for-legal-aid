module Providers
  class TaskListsController < ApplicationController
    before_action :authenticate_provider!
    before_action :update_locale
    include Authorizable
    include ApplicationDependable

    skip_back_history_for :show
    skip_provider_step_update_for :show

    def show
      legal_aid_application

      @task_list = ::TaskList::StartPageCollection.new(
        view_context, application: legal_aid_application
      )
    end

  private

    def legal_aid_application
      @legal_aid_application ||=
        LegalAidApplication.find_by(id: task_list_params[:legal_aid_application_id])
    end

    def task_list_params
      params.permit(%i[legal_aid_application_id locale])
    end
  end
end
