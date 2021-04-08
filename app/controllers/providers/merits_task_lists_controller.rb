module Providers
  class MeritsTaskListsController < ProviderBaseController
    def show
      @application_stages = application_stages
      @proceeding_stages = proceeding_stages
    end

    def update
      # update stage status to completed
      render :show
    end

    private

    def application_stages
      { title: 'Case details', stages: [
        { name: 'Latest incident details', status: 'Completed' },
        { name: 'Opponent details', status: 'Completed' },
        { name: 'Children involved in this application', status: 'Not started' },
        { name: 'Statement of case', status: 'Not started' }
      ] }
    end

    def proceeding_stages  # rubocop:disable Metrics/MethodLength:
      [
        { title: 'Non-molestation order', stages: [
          { name: 'Chances of success', status: 'Not started' }
        ] },
        { title: 'Prohibited steps order',
          stages: [
            { name: 'Children covered by proceeding', status: 'Cannot start yet' },
            { name: 'Attempts to settle', status: 'Not started' },
            { name: 'Chances of success', status: 'Not started' }
          ] },
        { title: 'Child arrangements order (residence)', stages: [
          { name: 'Children covered by proceeding', status: 'Cannot start yet' },
          { name: 'Attempts to settle', status: 'Not started' },
          { name: 'Chances of success', status: 'Not started' }
        ] }
      ]
    end
  end
end
