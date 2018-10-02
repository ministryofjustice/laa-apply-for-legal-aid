class LegalAidApplicationSerializer < ActiveModel::Serializer
  attribute :application_ref, key: :id

  belongs_to :applicant
  has_many :proceeding_types
end
