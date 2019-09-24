class SlackAlertSenderWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(message)
    SlackAlertSender.call(message)
  end
end
