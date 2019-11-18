class PdfConverterWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(attachment_id)
    PdfConverter.call(attachment_id)
  end
end
