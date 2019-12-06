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
    puts ">>> Event received: #{name}, payload: #{payload.inspect}"
    case name
    when 'dashboard.application_created'
      application_created
    when 'dashboard.provider_created'
      provider_created
    when 'dashboard.ccms_submission_saved'
      ccms_submission_saved
    when 'dashboard.firm_created'
      firm_created
    when 'dashboard.feedback_created'
      feedback_created
    when 'dashboard.merits_assessment_submitted'
      merits_assessment_submitted
    else
      raise UnrecognisedEventError.new("Unrecognised event: #{name}")
    end
  end

  private

  def application_created
    Dashboard::UpdaterJob.perform_later('StartedApplications') if payload[:state] == 'initiated'
  end

  def provider_created
    Dashboard::UpdaterJob.perform_later('DailyNewProviders')
  end

  def ccms_submission_saved
    Dashboard::UpdaterJob.perform_in(1.minute, 'FailedCcmsSubmissions') if payload[:state] == 'failed'

    Dashboard::UpdaterJob.perform_in(1.minute, 'PendingCcmsSubmissions') unless payload[:state].in?(%w[failed completed])
  end

  def firm_created
    Dashboard::UpdaterJob.perform_later('NumberProviderFirms')
  end

  def feedback_created
    Dashboard::UpdaterJob.perform_later('PastThreeWeeksAverageFeedbackScore')
    Dashboard::UpdaterJob.perform_later('PastWeeksAverageFeedbackScore')
  end

  def merits_assessment_submitted
    Dashboard::UpdaterJob.perform_later('SubmittedApplications')
  end


end
