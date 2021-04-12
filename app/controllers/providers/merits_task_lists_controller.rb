module Providers
  class MeritsTaskListsController < ProviderBaseController
    def show
      @merits_tasks = merits_tasks
    end

    private

    def merits_tasks
      YAML.load(LegalFramework::MeritsTasksService.call(@legal_aid_application).serialized_data).tasks # rubocop:disable Security/YAMLLoad:
    end
  end
end
