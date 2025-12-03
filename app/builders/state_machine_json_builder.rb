class StateMachineJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      legal_aid_application_id:,
      type:,
      aasm_state:,
      created_at:,
      updated_at:,
      ccms_reason:,
    }
  end
end
