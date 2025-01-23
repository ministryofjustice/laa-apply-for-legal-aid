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

  def stub_proceeding_search_for(term)
    body = proceeding_search_term_stubs[term]

    proxy
      .stub("https://legal-framework-api-staging.cloud-platform.service.justice.gov.uk:443/proceeding_types/searches", method: "post")
      .and_return(
        headers: {
          "Access-Control-Allow-Origin" => "*",
        },
        code: 200,
        body: body.to_json,
      )
  end

  def before_puffing_billy_stubs
    proxy
      .stub(/https:\/\/accounts\.google\.com/, method: "all")
      .and_return(code: 200, body: "")

    proxy
      .stub(/content-autofill\.googleapis\.com/)
      .and_return(code: 200, body: "")

    proxy
    .stub(%r{https://legal-framework-api-staging\.cloud-platform\.service\.justice\.gov\.uk.*/organisation_searches}, method: "options")
    .and_return(
      headers: {
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Headers" => "Content-Type",
      },
      code: 200,
    )

    proxy
      .stub(%r{https://legal-framework-api-staging\.cloud-platform\.service\.justice\.gov\.uk.*/proceeding_types/searches}, method: "options")
      .and_return(
        headers: {
          "Access-Control-Allow-Origin" => "*",
          "Access-Control-Allow-Headers" => "Content-Type",
        },
        code: 200,
      )
  end

private

  def organisation_search_term_stubs
    Hash.new({ success: false, data: [] }.freeze).merge(
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

  def proceeding_search_term_stubs
    Hash.new({ success: false, data: [] }.freeze).merge(
      {
        "Non-molestation order" =>
        {
          success: true,
          data: [
            {
              meaning: "Non-molestation order",
              ccms_code: "DA004",
              description: "to be represented on an application for a non-molestation order.",
              full_s8_only: false,
              ccms_category_law: "Family",
              ccms_matter: "domestic abuse (DA)",
            },
          ],
        },
        "injunction" =>
        {
          success: true,
          data: [
            {
              meaning: "Inherent jurisdiction high court injunction",
              ccms_code: "DA001",
              description: "to be represented on an application for an injunction, order or declaration under the inherent jurisdiction of the court.",
              full_s8_only: false,
              ccms_category_law: "Family",
              ccms_matter: "domestic abuse (DA)",
            },
            {
              meaning: "Harassment - injunction",
              ccms_code: "DA003",
              description: "to be represented in an action for an injunction under section 3 Protection from Harassment Act 1997.",
              full_s8_only: false,
              ccms_category_law: "Family",
              ccms_matter: "domestic abuse (DA)",
            },
          ],
        },
        "Occupation order" =>
        {
          success: true,
          data: [
            {
              meaning: "Occupation order",
              ccms_code: "DA005",
              description: "to be represented on an application for an occupation order.",
              full_s8_only: false,
              ccms_category_law: "Family",
              ccms_matter: "domestic abuse (DA)",
            },
          ],
        },
        "FGM Protection Order" =>
        {
          success: true,
          data: [
            {
              meaning: "FGM Protection Order",
              ccms_code: "DA020",
              description: "To be represented on an application for a Female Genital Mutilation Protection Order under the Female Genital Mutilation Act.",
              full_s8_only: false,
              ccms_category_law: "Family",
              ccms_matter: "domestic abuse (DA)",
            },
          ],
        },
        "Harassment - injunction" =>
        {
          success: true,
          data: [
            {
              meaning: "Harassment - injunction",
              ccms_code: "DA003",
              description: "to be represented in an action for an injunction under section 3 Protection from Harassment Act 1997.",
              full_s8_only: false,
              ccms_category_law: "Family",
              ccms_matter: "domestic abuse (DA)",
            },
            {
              meaning: "Non-molestation order",
              ccms_code: "DA004",
              description: "to be represented on an application for a non-molestation order.",
              full_s8_only: false,
              ccms_category_law: "Family",
              ccms_matter: "domestic abuse (DA)",
            },
          ],
        },
        "Child arrangements" =>
        {
          success: true,
          data: [
            {
              meaning: "Child arrangements order (residence)",
              ccms_code: "SE014",
              description: "to be represented on an application for a child arrangements order - where the child(ren) will live",
              full_s8_only: false,
              ccms_category_law: "Family",
              ccms_matter: "section 8 children (S8)",
            },
          ],
        },
      },
    )
  end
end

World(PuffingBillyHelper)
