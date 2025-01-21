RSpec::Matchers.define :have_completed_task do |group, task_name|
  description { "have task in a \"completed\" state" }

  match do |actual|
    expect(actual).to have_task_in_state(group, task_name, :complete)
  end
end

RSpec::Matchers.define :have_not_started_task do |group, task_name|
  description { "have task in a \"not started\" state" }

  match do |actual|
    expect(actual).to have_task_in_state(group, task_name, :not_started)
  end
end

RSpec::Matchers.define :have_task_in_state do |group, task_name, expected_state|
  description { "have task in the expected state" }

  match do |actual|
    possible_tasks = actual.task_list.tasks[group.to_sym] || actual.task_list.tasks.dig(:proceedings, group.to_sym, :tasks)
    if possible_tasks.nil?
      @error_message = "No group named ':#{group}' exists"
      break
    end

    @found_task = possible_tasks.find { |task| task.name == task_name.to_sym }
    if @found_task.nil?
      @error_message = "No task named '#{task_name}' exists in group named ':#{group}'"
      break
    end

    @found_task.state == expected_state
  end

  failure_message do
    @error_message ||= "The [:#{group}][:#{task_name}] task is set to :#{@found_task.state}, not :#{expected_state}'"
  end

  failure_message_when_negated do
    @error_message ||= "The [:#{group}][:#{task_name}] task is set to :#{@found_task.state} but expected to not be"
  end
end
