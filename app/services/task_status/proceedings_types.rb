module TaskStatus
  class ProceedingsTypes < Base
    def call
      Task::Status::NOT_STARTED
    end
  end
end
