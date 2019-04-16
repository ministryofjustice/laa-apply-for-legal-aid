class StatusController < ApiController
  def index
    render json: {
      redis: redis_connection,
      db: db,
      malware_scanner: {
        positive: malware_scanner_positive,
        negative: malware_scanner_negative
      }
    }
  end

  private

  def db
    LegalAidApplication.select(:id).first
    true
  end

  def redis_connection
    Sidekiq.redis(&:ping) == 'PONG'
  end

  def malware_scanner_positive
    virus_found = MalwareScanner.call(
      file_path: Rails.root.join('spec/fixtures/files/malware.doc'),
      save_result: false
    ).virus_found

    throw 'MalwareScanner fails to identify virus' unless virus_found

    true
  end

  def malware_scanner_negative
    virus_found = MalwareScanner.call(
      file_path: Rails.root.join('spec/fixtures/files/documents/hello_world.pdf'),
      save_result: false
    ).virus_found

    throw 'MalwareScanner wrongly flags safe file' if virus_found

    true
  end
end
