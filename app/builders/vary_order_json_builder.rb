class VaryOrderJsonBuilder
  extend NilSafeBuilder

  def initialize(vary_order)
    @vary_order = vary_order
  end

  attr_reader :vary_order

  delegate :id,
           :details,
           :created_at,
           :updated_at,
           to: :vary_order

  def as_json
    return unless vary_order

    {
      id:,
      details:,
      created_at:,
      updated_at:,
    }
  end
end
