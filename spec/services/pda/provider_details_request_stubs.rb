###################
# provider offices
###################
def stub_provider_offices
  stub_request(:get, %r{#{Rails.configuration.x.pda.url}/provider-user/test-user/provider-offices})
    .to_return(
      status: 200,
      body: provider_offices_json,
      headers: { "Content-Type" => "application/json; charset=utf-8" },
    )
end

def provider_offices_json
  {
    firm: {
      ccmsFirmId: 99_999,
      firmId: 1639,
      firmName: "Test firm",
      firmNumber: "1639",
    },
    officeCodes: [
      {
        ccmsFirmOfficeId: 111_111,
        firmOfficeCode: "1A111B",
      },
    ],
    user: {
      ccmsContactId: 494_000,
    },
  }.to_json
end

def stub_other_provider_offices
  stub_request(:get, %r{#{Rails.configuration.x.pda.url}/provider-user/other-user/provider-offices})
    .to_return(
      status: 200,
      body: other_provider_offices_json,
      headers: { "Content-Type" => "application/json; charset=utf-8" },
    )
end

def other_provider_offices_json
  {
    firm: {
      ccmsFirmId: 99_999,
      firmId: 1639,
      firmName: "Test firm",
      firmNumber: "1639",
    },
    officeCodes: [
      {
        ccmsFirmOfficeId: 222_222,
        firmOfficeCode: "2A222B",
      },
    ],
    user: {
      ccmsContactId: 494_000,
    },
  }.to_json
end

#################
# firm offices
#################
def stub_provider_firm_offices
  stub_request(:get, %r{#{Rails.configuration.x.pda.url}/provider-firms/1639/provider-offices})
  .to_return(
    status: 200,
    body: provider_firm_offices_json,
    headers: { "Content-Type" => "application/json; charset=utf-8" },
  )
end

def provider_firm_offices_json
  {
    firm: {
      ccmsFirmId: 99_999,
      firmId: 1639,
      firmName: "Test firm",
      firmNumber: "1639",
    },
    offices: [
      {
        ccmsFirmOfficeId: 111_111,
        firmOfficeCode: "1A111B",
      },
      {
        ccmsFirmOfficeId: 222_222,
        firmOfficeCode: "2A222B",
      },
    ],
  }.to_json
end

#################
# errors
#################
def stub_provider_details_retriever_record_not_found(provider:)
  stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-user/#{provider.username}/provider-offices")
    .to_return(body: nil, status: 204)
end

def stub_provider_details_retriever_api_error(provider:)
  stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-user/#{provider.username}/provider-offices")
    .to_return(body: "An error has occurred", status: 500)
end
