class ApplicantSerializer
  include FastJsonapi::ObjectSerializer
  attribute :first_name, :last_name, :email_address, :date_of_birth, :national_insurance_number
  #attribute :date_of_birth
end
