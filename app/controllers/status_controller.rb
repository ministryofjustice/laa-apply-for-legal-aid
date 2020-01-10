class StatusController < ApiController
  def status
    checks = {
      database: database_alive?,
      redis: redis_alive?,
      sidekiq: sidekiq_alive?,
      sidekiq_queue: sidekiq_queue_healthy?,

      malware_scanner: {
        positive: malware_scanner_positive,
        negative: malware_scanner_negative
      }
    }

    status = :bad_gateway unless checks.except(:sidekiq_queue).values.all?
    render status: status, json: { checks: checks }
  end

  def ping
    render json: {
      'build_date' => ENV['BUILD_DATE'] || 'Not Available',
      'commit_id' => ENV['COMMIT_ID'] || 'Not Available',
      'build_tag' => ENV['BUILD_TAG'] || 'Not Available',
      'app_branch' => ENV['APP_BRANCH'] || 'Not Available'
    }
  end

  private

  def redis_alive?
    Sidekiq.redis(&:info)
    true
  rescue StandardError
    false
  end

  def sidekiq_alive?
    ps = Sidekiq::ProcessSet.new
    !ps.size.zero?
  rescue StandardError
    false
  end

  def sidekiq_queue_healthy?
    dead = Sidekiq::DeadSet.new
    retries = Sidekiq::RetrySet.new
    dead.size.zero? && retries.size.zero?
  rescue StandardError
    false
  end

  def database_alive?
    ActiveRecord::Base.connection.active?
  rescue PG::ConnectionBad
    false
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
