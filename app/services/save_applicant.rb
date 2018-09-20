class SaveApplicant
  def self.call(**applicant_details)
    new.call(**applicant_details)
  end

  def call(**applicant_details)
    applicant = Applicant.new(applicant_details.except(:application_ref))
    app = LegalAidApplication.find_by(application_ref: applicant_details[:application_ref])
    if applicant.valid? && app
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
    def initialize(errors, success, applicant = nil)
      @errors = errors
      @success = success
      @applicant = applicant
    end

    def success?
      @success
    end
  end
end
