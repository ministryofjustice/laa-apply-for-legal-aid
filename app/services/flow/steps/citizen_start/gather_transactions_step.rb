module Flow
  module Steps
    module CitizenStart
      GatherTransactionsStep = Step.new(
        forward: :accounts,
      )
    end
  end
end
