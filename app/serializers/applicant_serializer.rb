class ApplicantSerializer
  include FastJsonapi::ObjectSerializer
  attribute :name
  attribute :date_of_birth
end
