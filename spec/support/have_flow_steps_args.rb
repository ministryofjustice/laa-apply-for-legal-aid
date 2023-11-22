RSpec::Matchers.define :have_flow_step_args do |expected|
  results = { path: nil, forward: nil, check_answers: nil }

  match do |actual|
    results = []
    results << "expected #{actual.path.call(legal_aid_application)} to equal #{expected[:path]}\n" unless actual.path.call(legal_aid_application) == expected[:path]
    if actual.forward.is_a?(Proc)
      results << "expected #{actual.forward.call(legal_aid_application, args)} to equal #{expected[:forward]}\n" unless actual.forward.call(legal_aid_application, args) == expected[:forward]
    else
      results << "expected #{actual.forward} to equal #{expected[:forward]}\n" unless actual.forward == expected[:forward]
    end
    results << "expected #{actual.check_answers} to equal #{expected[:check_answers]}\n" unless actual.check_answers == expected[:check_answers]
    results.empty?
  end

  failure_message do |_actual|
    results.join("\n")
  end

  description do
    "have matching flow step arguments"
  end
end
