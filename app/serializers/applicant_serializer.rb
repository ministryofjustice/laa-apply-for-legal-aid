class ApplicantSerializer
  include FastJsonapi::ObjectSerializer
  attribute :first_name, :last_name
  attribute :date_of_birth
end
