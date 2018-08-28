class LegalAidApplicationSerializer
  include FastJsonapi::ObjectSerializer
  attribute :application_ref
  belongs_to :applicant
end
