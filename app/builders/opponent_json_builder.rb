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
    }
  end

private

  def opposable
    if opposable_type == "ApplicationMeritsTask::Organisation"
      OrganisationJsonBuilder.build(object.opposable).as_json
    else
      IndividualJsonBuilder.build(object.opposable).as_json
    end
  end
end
