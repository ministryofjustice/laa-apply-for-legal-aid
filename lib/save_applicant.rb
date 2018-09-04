class SaveApplicant
  def self.call(*args)
    new.call(*args)
  end

  def call(name:, date_of_birth:)
    applicant = Applicant.new(name: name, date_of_birth: date_of_birth)
    [applicant, applicant.save]
  end
end
