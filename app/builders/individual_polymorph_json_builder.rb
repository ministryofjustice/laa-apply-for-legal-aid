class IndividualPolymorphJsonBuilder < BaseJsonBuilder
  def as_json
    {
      first_name:,
      last_name:,
      date_of_birth:,
      details:,
      type:,

    }
  end

private

  def details
    { todo: "Details like addresses?" }
  end

  def type
    case object
    when Applicant
      "CLIENT"
    else
      Rails.logger.warn("Unknown individual type for polymorph: #{object.class.name}")
      "UNKNOWN"
    end
  end
end
