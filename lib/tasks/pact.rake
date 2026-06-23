namespace :pact do
  namespace :consumer do
    desc "Generate pact files for all consumer contracts"
    task generate: :environment do
      system("bundle exec rspec -t pact")
    end

    desc "Publish pact files for all consumer contracts to pact broker"
    task publish: :environment do
      raise "PACT_BROKER_BASE_URL environment variable is required to publish pacts" if ENV["PACT_BROKER_BASE_URL"].blank?
      raise "PACT_BROKER_USERNAME environment variable is required to publish pacts" if ENV["PACT_BROKER_USERNAME"].blank?
      raise "PACT_BROKER_PASSWORD environment variable is required to publish pacts" if ENV["PACT_BROKER_PASSWORD"].blank?

      broker_url = ENV.fetch("PACT_BROKER_BASE_URL")
      broker_username = ENV.fetch("PACT_BROKER_USERNAME")
      broker_password = ENV.fetch("PACT_BROKER_PASSWORD")
      consumer_version = ENV.fetch("GITHUB_SHA", nil) || `git rev-parse HEAD`.strip

      branch =
        ENV["GITHUB_HEAD_REF"].presence ||
        ENV["GITHUB_REF_NAME"].presence ||
        ENV.fetch("BRANCH_NAME", nil)

      command = [
        "bundle",
        "exec",
        "pact-broker",
        "publish",
        "spec/pacts",
        "--broker-base-url",
        broker_url,
        "--broker-username",
        broker_username,
        "--broker-password",
        broker_password,
        "--consumer-app-version",
        consumer_version,
      ]

      command += ["--branch", branch] if branch.present?

      puts "Publishing pacts..."
      puts command.join(" ")

      success = system(*command)

      abort("Pact publish failed") unless success
    end
  end
end
