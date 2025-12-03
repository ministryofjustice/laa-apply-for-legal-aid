def stub_successful_datastore_submission
  stub_request(:post, %r{(http|https).*laa-data-access-api.*\.cloud-platform\.service\.justice\.gov\.uk/api/v0/.*})
     .to_return(
       status: 201,
       body: { message: "Submission created successfully" }.to_json,
       headers: { "Content-Type" => "application/json; charset=utf-8" },
     )
end

# TODO: AP-6378 - this can be removed once the hoped for response body is confirmed
def stub_successful_datastore_submission_without_body
  stub_request(:post, %r{(http|https).*laa-data-access-api.*\.cloud-platform\.service\.justice\.gov\.uk/api/v0/.*})
     .to_return(
       status: 201,
       body: "",
       headers: { "Content-Type" => "application/json; charset=utf-8" },
     )
end

def stub_bad_request_datastore_submission
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
       headers: { "Content-Type" => "application/json; charset=utf-8" },
     )
end

def stub_unauthorized_datastore_submission
  stub_request(:post, %r{(http|https).*laa-data-access-api.*\.cloud-platform\.service\.justice\.gov\.uk/api/v0/.*})
     .to_return(
       status: 401,
       body: {
         type: "about:blank",
         title: "Unauthorized",
         status: 401,
         detail: "Check your request was has been authorized",
         instance: "/api/v0/applications",
       }.to_json,
       headers: { "Content-Type" => "application/json; charset=utf-8" },
     )
end

def stub_forbidden_datastore_submission
  stub_request(:post, %r{(http|https).*laa-data-access-api.*\.cloud-platform\.service\.justice\.gov\.uk/api/v0/.*})
     .to_return(
       status: 403,
       body: {
         type: "about:blank",
         title: "Forbidden",
         status: 403,
         detail: "Check your request was has been authenticated",
         instance: "/api/v0/applications",
       }.to_json,
       headers: { "Content-Type" => "application/json; charset=utf-8" },
     )
end

def stub_internal_server_error_datastore_submission
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
       headers: { "Content-Type" => "application/json; charset=utf-8" },
     )
end
