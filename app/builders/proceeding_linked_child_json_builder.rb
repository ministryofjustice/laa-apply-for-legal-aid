class ProceedingLinkedChildJsonBuilder
  extend NilSafeBuilder

  def initialize(proceeding_linked_child)
    @proceeding_linked_child = proceeding_linked_child
  end

  attr_reader :proceeding_linked_child

  delegate :id,
           :involved_child_id,
           :created_at,
           :updated_at,
           to: :proceeding_linked_child

  def as_json
    return unless proceeding_linked_child

    {
      id:,
      involved_child_id:,
      created_at:,
      updated_at:,
    }
  end
end
