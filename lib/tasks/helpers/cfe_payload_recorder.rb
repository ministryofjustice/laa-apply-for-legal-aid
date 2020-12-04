class CfePayloadRecorder

  def self.call(application_ref)
    new(application_ref).call
  end

  def initialize(application_ref)
    @legal_aid_application = LegalAidApplication.find_by(application_ref: application_ref)
    raise ArgumentError.new('No such application') if @legal_aid_application.nil?
    @recording = []
  end

  def call
    submission = @legal_aid_application.most_recent_cfe_submission
    submission.submission_histories.each do |history|
      record_history(history)
    end
    puts "# CFE API calls for applicaiton #{@legal_aid_application.application_ref}"
    puts @recording.to_yaml
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
