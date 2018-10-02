class ProceedingTypeSerializer < ActiveModel::Serializer
  attributes :code, :meaning, :description

  attribute :ccms_category_law, key: :category_law
  attribute :ccms_matter, key: :matter
end
