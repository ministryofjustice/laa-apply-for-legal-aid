class ProceedingTypesSerializer
  include FastJsonapi::ObjectSerializer

  attributes :code, :meaning, :description

  attribute :category_law do |object|
    object.ccms_category_law.to_s
  end

  attribute :matter do |object|
    object.ccms_matter.to_s
  end
end
