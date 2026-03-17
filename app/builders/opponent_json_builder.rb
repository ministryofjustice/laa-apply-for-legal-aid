class OpponentJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      legal_aid_application_id:,
      created_at:,
      updated_at:,
      ccms_opponent_id:,
      opposable_type:,
      opposable_id:,
      exists_in_ccms:,
      opposable:,

      # Mappings used by Datastore/Decide
      opponent_type:,
      first_name:,
      last_name:,
      organisation_name:,
    }
  end

private

  # Enum for Datastore/Decide
  def opponent_type
    case opposable_type
    when "ApplicationMeritsTask::Organisation"
      "ORGANISATION"
    when "ApplicationMeritsTask::Individual"
      "INDIVIDUAL"
    end
  end

  def first_name
    object.opposable.first_name if object.opposable.respond_to?(:first_name)
  rescue NameError
    nil
  end

  def last_name
    object.opposable.last_name if object.opposable.respond_to?(:last_name)
  rescue NameError
    nil
  end

  def organisation_name
    object.opposable.name if object.opposable.respond_to?(:name)
  rescue NameError
    nil
  end

  # Full object for Civil Apply "rehydration", eventually
  def opposable
    case opposable_type
    when "ApplicationMeritsTask::Organisation"
      OrganisationJsonBuilder.build(object.opposable).as_json
    when "ApplicationMeritsTask::Individual"
      IndividualJsonBuilder.build(object.opposable).as_json
    end
  end
end
