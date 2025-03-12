module TaskStatus
  class HasNationalInsuranceNumbers < Base
    def call
      Task::Status::NOT_STARTED
    end
  end
end
