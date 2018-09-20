class ApplicantSerializer
  include FastJsonapi::ObjectSerializer
  attribute :first_name, :last_name, :email_address
  attribute :date_of_birth
end
