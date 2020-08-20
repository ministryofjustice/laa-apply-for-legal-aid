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
    @name_parts ||= name.to_s.split('.')
  end

  def name_matches?
    name_parts[0].eql?('dashboard') && valid_events.include?(name_parts[1])
  end

  def method_to_call
    @name_parts[1]
  end

  def valid_events
    %w[application_created provider_created ccms_submission_saved firm_created feedback_created application_submitted] +
      %w[merits_assessment_submitted delegated_functions_used declined_open_banking]
  end

  def application_created
    Dashboard::UpdaterJob.perform_later('Applications') if payload[:state] == 'initiated'
  end

  def provider_created
    Dashboard::UpdaterJob.perform_later('DailyNewProviders')
  end

  def ccms_submission_saved
    Dashboard::UpdaterJob.perform_later('Applications') if payload[:state] == 'failed'
    Dashboard::UpdaterJob.set(wait: 1.minute).perform_later('PendingCcmsSubmissions') unless payload[:state].in?(%w[failed completed])
  end

  def declined_open_banking
    Dashboard::UpdaterJob.perform_later('PercentageDeclinedOpenBanking')
  end

  def firm_created
    Dashboard::UpdaterJob.perform_later('NumberProviderFirms')
  end

  def feedback_created
    Dashboard::UpdaterJob.perform_later('FeedbackScores')
    Dashboard::FeedbackItemJob.perform_later(Feedback.find(payload[:feedback_id]))
  end

  def application_submitted
    Dashboard::UpdaterJob.perform_later('Applications')
  end

  def delegated_functions_used
    Dashboard::UpdaterJob.perform_later('Applications')
  end
end
