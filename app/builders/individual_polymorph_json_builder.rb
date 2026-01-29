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

  # TODO: Implement other individual types when we know what the API intends. Partners, Involved children, opponents.
  def type
    "CLIENT"
  end
end
