class PdfConverterWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(original_file_id)
    PdfConverter.call(original_file_id)
  end
end
