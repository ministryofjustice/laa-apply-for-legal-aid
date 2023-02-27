def sign_in_citizen_for_application(legal_aid_application)
  access_token = legal_aid_application.generate_citizen_access_token!
  get citizens_legal_aid_application_path(access_token.token)
end
