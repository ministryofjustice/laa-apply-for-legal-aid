class DashboardEventHandler
  class UnrecognisedEventError < RuntimeError; end
  delegate :name, :payload, to: :event

  attr_reader :event

  def initialize(event)
    @event = event
  end

  def self.call(event)
    new(event).call
  end

  def call
    raise UnrecognisedEventError, "Unrecognised event: #{name}" unless name_matches?

    method(method_to_call).call
  end

private

  def name_parts
    @name_parts ||= name.to_s.split(".")
  end

  def name_matches?
    name_parts[0].eql?("dashboard") && valid_events.include?(name_parts[1])
  end

  def method_to_call
    @name_parts[1]
  end

  def valid_events
    %w[application_created
       provider_updated
       ccms_submission_saved
       firm_created
       application_submitted
       declined_open_banking]
  end

  def application_created
    Dashboard::UpdaterJob.perform_later("Applications") if payload[:state] == "initiated"
  end

  def provider_updated
    Dashboard::ProviderDataJob.perform_later(Provider.find(payload[:provider_id]))
  end

  def ccms_submission_saved
    Dashboard::UpdaterJob.perform_later("Applications") if payload[:state].in?(%w[failed completed])
    Dashboard::UpdaterJob.set(wait: 1.minute).perform_later("PendingCCMSSubmissions") if payload[:state].in?(%w[initialised failed abandoned completed])
  end

  def declined_open_banking
    Dashboard::UpdaterJob.perform_later("PercentageDeclinedOpenBanking")
  end

  def firm_created
    Dashboard::UpdaterJob.perform_later("NumberProviderFirms")
  end

  def application_submitted
    Dashboard::UpdaterJob.perform_later("Applications")
  end
end
