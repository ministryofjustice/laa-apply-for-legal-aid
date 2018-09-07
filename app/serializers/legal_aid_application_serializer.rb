class LegalAidApplicationSerializer
  include FastJsonapi::ObjectSerializer
  attribute :application_ref
  has_many :proceeding_types
  belongs_to :applicant
end
