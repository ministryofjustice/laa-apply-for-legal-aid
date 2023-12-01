module PuffingBillyHelper
  def stub_organisation_search_for(term)
    body = organisation_search_term_stubs[term]

    proxy
      .stub("https://legal-framework-api-staging.cloud-platform.service.justice.gov.uk:443/organisation_searches", method: "post")
      .and_return(
        headers: {
          "Access-Control-Allow-Origin" => "*",
        },
        code: 200,
        body: body.to_json,
      )
  end

  def organisation_search_term_stubs
    Hash.new({ success: false, data: [] }).merge(
      {
        "bab" =>
        {
          success: true,
          data: [
            {
              name: "Babergh District Council",
              ccms_opponent_id: "280370",
              ccms_type_code: "LA",
              ccms_type_text: "Local Authority",
              name_headline: "<mark>Babergh</mark> District Council",
              type_headline: "Local Authority",
            },
          ],
        },
        "ang" =>
        {
          success: true,
          data: [
            {
              name: "Angus Council",
              ccms_opponent_id: "280361",
              ccms_type_code: "LA",
              ccms_type_text: "Local Authority",
              name_headline: "<mark>Angus</mark> Council",
              type_headline: "Local Authority",
            },
            {
              name: "Isle of Anglesey County Council",
              ccms_opponent_id: "281357",
              ccms_type_code: "LA",
              ccms_type_text: "Local Authority",
              name_headline: "Isle of <mark>Anglesey</mark> County Council",
              type_headline: "Local Authority",
            },
          ],
        },
        "ang loc" =>
        {
          success: true,
          data: [
            {
              name: "Angus Council",
              ccms_opponent_id: "280361",
              ccms_type_code: "LA",
              ccms_type_text: "Local Authority",
              name_headline: "<mark>Angus</mark> Council",
              type_headline: "<mark>Local</mark> Authority",
            },
            {
              name: "Isle of Anglesey County Council",
              ccms_opponent_id: "281357",
              ccms_type_code: "LA",
              ccms_type_text: "Local Authority",
              name_headline: "Isle of <mark>Anglesey</mark> County Council",
              type_headline: "<mark>Local</mark> Authority",
            },
          ],
        },
        "prison r" =>
        {
          success: true,
          data: [
            {
              name: "Ranby",
              ccms_opponent_id: "379046",
              ccms_type_code: "HMO",
              ccms_type_text: "HM Prison or Young Offender Institute",
              name_headline: "<mark>Ranby</mark>",
              type_headline: "HM <mark>Prison</mark> or Young Offender Institute",
            },
            {
              name: "Risley",
              ccms_opponent_id: "380677",
              ccms_type_code: "HMO",
              ccms_type_text: "HM Prison or Young Offender Institute",
              name_headline: "<mark>Risley</mark>",
              type_headline: "HM <mark>Prison</mark> or Young Offender Institute",
            },
            {
              name: "Rye Hill",
              ccms_opponent_id: "380678",
              ccms_type_code: "HMO",
              ccms_type_text: "HM Prison or Young Offender Institute",
              name_headline: "<mark>Rye</mark> Hill",
              type_headline: "HM <mark>Prison</mark> or Young Offender Institute",
            },
          ],
        },
      },
    )
  end

  def before_puffing_billy_stubs
    proxy
      .stub(/content-autofill\.googleapis\.com/)
      .and_return(code: 200, body: "")

    proxy
    .stub(%r{https://legal-framework-api-staging\.cloud-platform.service\.justice\.gov\.uk.*/organisation_searches}, method: "options")
    .and_return(
      headers: {
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Headers" => "Content-Type",
      },
      code: 200,
    )

    proxy
      .stub(%r{https://legal-framework-api-staging\.cloud-platform.service\.justice.gov\.uk.*/proceeding_types/searches}, method: "options")
      .and_return(
        headers: {
          "Access-Control-Allow-Origin" => "*",
          "Access-Control-Allow-Headers" => "Content-Type",
        },
        code: 200,
      )
  end
end

World(PuffingBillyHelper)
