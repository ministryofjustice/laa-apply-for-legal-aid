class SaveApplicant

  def save_applicant(name: ,date_of_birth:)
    applicant = Applicant.new(name: name , date_of_birth: date_of_birth )
    return applicant , applicant.save
  end

end
