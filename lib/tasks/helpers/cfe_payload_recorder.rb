class CfePayloadRecorder
  def self.call(application_ref)
    new(application_ref).call
  end

  def initialize(application_ref)
    @legal_aid_application = LegalAidApplication.find_by(application_ref: application_ref)
    raise ArgumentError, 'No such application' if @legal_aid_application.nil?

    @recording = []
  end

  def call
    submission = @legal_aid_application.most_recent_cfe_submission
    submission.submission_histories.each do |history|
      record_history(history)
    end
    logger = Rails.logger
    logger.info '#'.yellow
    logger.info "# CFE API calls for application #{@legal_aid_application.application_ref}".yellow
    logger.info '# Copy and paste this output in to tmp/api_replay.yml in the CFE repo, and '.yellow
    logger.info '# replay the API interaction with the rake task rake replay'.yellow
    logger.info '#'.yellow
    logger.info @recording.to_yaml
  end

  private

  def record_history(history)
    hash = {}
    hash[:method] = history.http_method
    hash[:path] = extract_uri_path(history.url)
    hash[:payload] = history.request_payload
    @recording << hash
  end

  def extract_uri_path(url)
    uri = URI(url)
    uri.path
  end
end
