module Flow
  module Steps
    module CitizenStart
      LegalAidApplicationsStep = Step.new(
        forward: :consents,
      )
    end
  end
end
