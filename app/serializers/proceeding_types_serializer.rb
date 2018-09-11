class ProceedingTypesSerializer
  include FastJsonapi::ObjectSerializer

  attributes :ccms_category_law, :ccms_category_law_code, :ccms_matter, :ccms_matter_code, :meaning, :description


  attribute :proceeding_type_code do |object|
    "#{object.code}"
  end

  attribute :ccms_proceeding_code do |object|
    "#{object.ccms_code}"
  end

end
