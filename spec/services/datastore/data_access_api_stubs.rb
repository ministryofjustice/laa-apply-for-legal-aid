def stub_successful_refresh_token_request
  stub_request(:post, %r{https://login\.microsoftonline\.com/.*/oauth2/v2\.0/token})
    .to_return(
      status: 200,
      body: {
        access_token: "new_fake_access_token",
        refresh_token: "new_fake_refresh_token",
        expires_in: 3600,
        id_token: "new_fake_id_token",
        scope: "new_fake_scope",
      }.to_json,
      headers: { "content-type" => "application/json; charset=utf-8" },
    )
end

def stub_expired_refresh_token_request
  stub_request(:post, %r{https://login\.microsoftonline\.com/.*/oauth2/v2\.0/token})
    .to_return(
      status: 400,
      body: {
        error: "invalid_grant",
        error_description: "AADSTS999999: The refresh token has expired due to inactivity...",
      }.to_json,
      headers: { "content-type" => "application/json; charset=utf-8" },
    )
end

def stub_other_failed_refresh_token_request
  stub_request(:post, %r{https://login\.microsoftonline\.com/.*/oauth2/v2\.0/token})
    .to_return(
      status: 400,
      body: {
        error: "invalid_request",
        error_description: "AADSTS999999: Something went wrong...",
      }.to_json,
      headers: { "content-type" => "application/json; charset=utf-8" },
    )
end

# Realistic stub at time of wrirting - returns 201 with Location header but no body
def stub_successful_datastore_submission
  stub_successful_refresh_token_request

  stub_request(:post, %r{(http|https).*laa-data-access-api.*\.cloud-platform\.service\.justice\.gov\.uk/api/v0/.*})
     .to_return(
       status: 201,
       body: "",
       headers: { "location" => "https://main-laa-data-access-api-uat.cloud-platform.service.justice.gov.uk/api/v0/applications/67359989-7268-47e7-b3f9-060ccff9b150" },
     )
end

def stub_bad_request_datastore_submission
  stub_successful_refresh_token_request

  stub_request(:post, %r{(http|https).*laa-data-access-api.*\.cloud-platform\.service\.justice\.gov\.uk/api/v0/.*})
     .to_return(
       status: 400,
       body: {
         type: "about:blank",
         title: "Bad request",
         status: 400,
         detail: "Check your request was valid",
         instance: "/api/v0/applications",
       }.to_json,
     )
end

def stub_unauthorized_datastore_submission
  stub_successful_refresh_token_request

  stub_request(:post, %r{(http|https).*laa-data-access-api.*\.cloud-platform\.service\.justice\.gov\.uk/api/v0/.*})
     .to_return(
       status: 401,
       body: {
         type: "about:blank",
         title: "Unauthorized",
         status: 401,
         detail: "Check your request has been authorized",
         instance: "/api/v0/applications",
       }.to_json,
     )
end

def stub_forbidden_datastore_submission
  stub_successful_refresh_token_request

  stub_request(:post, %r{(http|https).*laa-data-access-api.*\.cloud-platform\.service\.justice\.gov\.uk/api/v0/.*})
     .to_return(
       status: 403,
       body: {
         type: "about:blank",
         title: "Forbidden",
         status: 403,
         detail: "Check your request has been authenticated",
         instance: "/api/v0/applications",
       }.to_json,
     )
end

def stub_internal_server_error_datastore_submission
  stub_successful_refresh_token_request

  stub_request(:post, %r{(http|https).*laa-data-access-api.*\.cloud-platform\.service\.justice\.gov\.uk/api/v0/.*})
     .to_return(
       status: 500,
       body: {
         type: "about:blank",
         title: "Internal server error",
         status: 500,
         detail: "An unexpected application error has occurred.",
         instance: "/api/v0/applications",
       }.to_json,
     )
end
