module Flow
  # Used to define the point in the flow by labels that are relevant to their place in the flow rather than the role of
  # the page itself. In particular, points where the flow forks, branches rejoin the flow, or the start/end of sequences.
  class KeyPoint
    KEY_POINTS = {
      citizens: {},
      providers: {
        home: :providers_home,
        journey_start: :applicants,
        edit_applicant: :applicant_details,
        start_after_applicant_completes_means: :client_completed_means,
        start_income_update: :capital_introductions,
        start_vehicle_journey: :vehicles,
        start_dwp_override: :confirm_dwp_non_passported_applications,
        check_benefits: :check_benefits
      }
    }.freeze

    def self.step_for(journey:, key_point:)
      new(journey, key_point).step
    end

    def self.path_for(journey:, key_point:, legal_aid_application: nil)
      new(journey, key_point).path(legal_aid_application)
    end

    attr_reader :journey, :key_point

    def initialize(journey, key_point)
      @journey = journey
      @key_point = key_point
    end

    def step
      KEY_POINTS.dig journey, key_point
    end

    def path(legal_aid_application)
      flow(legal_aid_application).current_path
    end

    private

    def flow((legal_aid_application))
      Flow::BaseFlowService.flow_service_for(
        journey,
        legal_aid_application: legal_aid_application,
        current_step: step
      )
    end
  end
end
