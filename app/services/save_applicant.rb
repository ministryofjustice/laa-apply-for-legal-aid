class SaveApplicant

  def self.call(name:, date_of_birth:, application_ref:)
    new.call(name: name, date_of_birth: date_of_birth, application_ref: application_ref)
  end

  def call(name:, date_of_birth:, application_ref:)
    applicant = Applicant.new(name: name, date_of_birth: date_of_birth)
    app = LegalAidApplication.find_by(application_ref: application_ref)

    if (applicant.valid? && app)
      applicant.save
      app.applicant = applicant
      app.save
      Result.new(nil, true, applicant)
    elsif app.nil?
      Result.new(['invalid application reference'], false)
    else
      Result.new(applicant.errors.full_messages, false)
    end
  end

  class Result
    attr_reader :applicant, :errors
    def initialize(errors, success, applicant=nil)
      @errors = errors
      @success = success
      @applicant = applicant
    end

    def success?
      @success
    end
  end
end
