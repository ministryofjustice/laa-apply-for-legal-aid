class OfficeJsonBuilder
  extend NilSafeBuilder

  def initialize(office)
    @office = office
  end

  attr_reader :office

  delegate :id,
           :created_at,
           :updated_at,
           :ccms_id,
           :code,
           :firm_id,
           to: :office

  def as_json
    return unless office

    {
      id:,
      created_at:,
      updated_at:,
      ccms_id:,
      code:,
      firm_id:,
    }
  end
end
