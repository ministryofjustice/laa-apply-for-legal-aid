SimpleCov.start "rails" do
  add_filter "config/"
  add_filter "spec/"
  add_filter "services/migration_helpers/"

  add_filter "lib/tasks/helpers/cfe_api_displayer.rb"
  add_filter "lib/tasks/helpers/cfe_payload_recorder.rb"
  add_filter "lib/tasks/helpers/cy_helper.rb"
  add_filter "lib/utilities/redis_scanner.rb"
  add_filter "app/controllers/pages_controller.rb"

  enable_coverage :branch

  unless ENV["CIRCLE_JOB"]
    minimum_coverage line: 100
    refuse_coverage_drop :line, :branch

    SimpleCov.at_exit do
      SimpleCov.result.format!
    end
  end
end
