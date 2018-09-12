class ProceedingTypesSerializer
  include FastJsonapi::ObjectSerializer

  attributes :ccms_category_law, :ccms_matter, :meaning, :description

  attribute :proceeding_type_code do |object|
    object.code.to_s
  end
end
