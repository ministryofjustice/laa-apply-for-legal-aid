class ProceedingTypeSerializer < ActiveModel::Serializer
  attributes :code, :meaning, :description, :additional_search_terms

  attribute :ccms_category_law, key: :category_law
  attribute :ccms_matter, key: :matter
end
