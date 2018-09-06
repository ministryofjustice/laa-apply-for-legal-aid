class SaveApplicant
  def self.call(name:, date_of_birth:, application_ref:)
    new.call(name: name, date_of_birth: date_of_birth, application_ref: application_ref)
  end

  def call(name:, date_of_birth:, application_ref:)
    applicant = Applicant.new(name: name, date_of_birth: date_of_birth)
    app = LegalAidApplication.find_by(application_ref: application_ref)
      result = false
      if app
        app.applicant = applicant
        app.save
        result = true
      else
        result = false
        errors = ['invalid application reference']
      end
    [applicant, result]
  end
end
