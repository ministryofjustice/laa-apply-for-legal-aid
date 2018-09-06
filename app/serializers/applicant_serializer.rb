class ApplicantSerializer
  include FastJsonapi::ObjectSerializer
  attribute :name
  attribute :date_of_birth
  attribute :legal_aid_application.application_ref
end
