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
        body: body.to_json.force_encoding("BINARY"),
      )
  end

  def stub_proceeding_search_for(term)
    body = proceeding_search_term_stubs[term]

    proxy
      .stub(%r{https://legal-framework-api-staging\.cloud-platform\.service\.justice\.gov\.uk.*/proceeding_types/searches}, method: "post")
      .and_return(
        headers: {
          "Access-Control-Allow-Origin" => "*",
          "Content-Type" => "application/json; charset=utf-8",
        },
        code: 200,
        body: body.to_json.force_encoding("BINARY"),
      )
  end

  def stub_countries_search_for(term)
    body = countries_search_term_stubs[term]

    proxy
      .stub(%r{https://legal-framework-api-staging\.cloud-platform\.service\.justice\.gov\.uk.*/countries/search}, method: "post")
      .and_return(
        headers: {
          "Access-Control-Allow-Origin" => "*",
          "Content-Type" => "application/json; charset=utf-8",
        },
        code: 200,
        body: body.to_json.force_encoding("BINARY"),
      )
  end

  def before_puffing_billy_stubs
    proxy
      .stub(/\.google\.com/, method: "all")
      .and_return(code: 200, body: "")

    proxy
      .stub(/\.googleapis\.com/, method: "all")
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

    proxy
      .stub(%r{https://legal-framework-api-staging\.cloud-platform\.service\.justice\.gov\.uk.*/countries/search}, method: "options")
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
        "cakes" =>
        {
          success: false,
          data: [],
        },
        "dom" =>
        {
          success: true,
          data: [
            {
              meaning: "Harassment - injunction",
              ccms_code: "DA003",
              description: "to be represented in an action for an injunction under section 3 Protection from Harassment Act 1997.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "domestic abuse (DA)",
            },
            {
              meaning: "Inherent jurisdiction - high court injunction",
              ccms_code: "DA001",
              description: "to be represented on an application for an injunction, order or declaration under the inherent jurisdiction of the court.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "domestic abuse (DA)",
            },
            {
              meaning: "Part IV - extend, vary or discharge",
              ccms_code: "DA006",
              description: "to be represented on an application to extend, vary or discharge an order under Part IV Family Law Act 1996",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "domestic abuse (DA)",
            },
            {
              meaning: "Female genital mutilation (FGM) protection order",
              ccms_code: "DA020",
              description: "To be represented on an application for a Female Genital Mutilation Protection Order under the Female Genital Mutilation Act.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "domestic abuse (DA)",
            },
            {
              meaning: "Occupation order",
              ccms_code: "DA005",
              description: "to be represented on an application for an occupation order.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "domestic abuse (DA)",
            },
            {
              meaning: "Non-molestation order",
              ccms_code: "DA004",
              description: "to be represented on an application for a non-molestation order.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "domestic abuse (DA)",
            },
            {
              meaning: "Forced marriage protection order",
              ccms_code: "DA007",
              description: "to be represented on an application for a forced marriage protection order",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "domestic abuse (DA)",
            },
            {
              meaning: "Protection from harassment act 1997 under section 5 - vary or discharge",
              ccms_code: "DA002",
              description: "to be represented on an application to vary or discharge an order under section 5 Protection from Harassment Act 1997 where the parties are associated persons (as defined by Part IV Family Law Act 1996).",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "domestic abuse (DA)",
            },
          ],
        },
        "Child arrangements order CAO Section 8" =>
        {
          success: true,
          data: [
            {
              meaning: "Child arrangements order (CAO) - residence - vary",
              ccms_code: "SE016",
              description: "to be represented on an application to vary or discharge a child arrangements order –where the child(ren) will live.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Child arrangements order (CAO) - contact - appeal",
              ccms_code: "SE013A",
              description: "to be represented on an application for a child arrangements order-who the child(ren) spend time with. Appeals only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Child arrangements order (CAO) - contact - enforcement",
              ccms_code: "SE013E",
              description: "to be represented on an application for a child arrangements order-who the child(ren) spend time with. Enforcement only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Child arrangements order (CAO) - residence - enforcement - vary",
              ccms_code: "SE016E",
              description: "to be represented on an application to vary or discharge a child arrangements order –where the child(ren) will live. Enforcement only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Child arrangements order (CAO) - residence",
              ccms_code: "SE014",
              description: "to be represented on an application for a child arrangements order –where the child(ren) will live",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Child arrangements order (CAO) - contact - appeal - vary",
              ccms_code: "SE015A",
              description: "to be represented on an application to vary/discharge a child arrangements order-who the child(ren) spend time with. Appeals only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Child arrangements order (CAO) - contact",
              ccms_code: "SE013",
              description: "to be represented on an application for a child arrangements order-who the child(ren) spend time with.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Child arrangements order (CAO) - contact - vary",
              ccms_code: "SE015",
              description: "to be represented on an application to vary/discharge a child arrangements order-who the child(ren) spend time with.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Child arrangements order (CAO) - contact - enforcement - vary",
              ccms_code: "SE015E",
              description: "to be represented on an application to vary/discharge a child arrangements order-who the child(ren) spend time with. Enforcement only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Child arrangements order (CAO) - residence - enforcement",
              ccms_code: "SE014E",
              description: "to be represented on an application for a child arrangements order –where the child(ren) will live. Enforcement only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Child arrangements order (CAO) - residence - appeal",
              ccms_code: "SE014A",
              description: "to be represented on an application for a child arrangements order –where the child(ren) will live. Appeals only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Child arrangements order (CAO) - residence - appeal - vary",
              ccms_code: "SE016A",
              description: "to be represented on an application to vary or discharge a child arrangements order –where the child(ren) will live. Appeals only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
          ],
        },
        "Enforcement order 11J" =>
        {
          success: true,
          data: [
            {
              meaning: "Enforcement order 11J",
              ccms_code: "SE095",
              description: "to be represented on an application for an enforcement order under section 11J Children Act 1989.  Enforcement only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Enforcement order 11J - appeal",
              ccms_code: "SE095A",
              description: "to be represented on an application for an enforcement order under section 11J Children Act 1989.  Appeals only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Enforcement order 11J - amendment following breach",
              ccms_code: "SE100E",
              description: "to be represented on an application, following breach, for an amendment to an enforcement order or for a further enforcement order under section 11J and Schedule A1 Children Act 1989.  Enforcement only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Enforcement order 11J and committal",
              ccms_code: "SE096E",
              description: "to be represented on an application for committal and for an enforcement order under section 11J Children Act 1989. Enforcement only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Enforcement order 11J - revocation",
              ccms_code: "SE097",
              description: "to be represented on an application for the revocation of an enforcement order under section 11J and Schedule A1 Children Act 1989.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Enforcement order 11J - revocation - appeal",
              ccms_code: "SE097A",
              description: "to be represented on an application for the revocation of an enforcement order under section 11J and Schedule A1 Children Act 1989.  Appeals only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
          ],
        },
        "Non-molestation order" =>
        {
          success: true,
          data: [
            {
              meaning: "Non-molestation order",
              ccms_code: "DA004",
              description: "to be represented on an application for a non-molestation order.",
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
              ccms_category_law: "Family",
              ccms_matter: "domestic abuse (DA)",
            },
            {
              meaning: "Harassment - injunction",
              ccms_code: "DA003",
              description: "to be represented in an action for an injunction under section 3 Protection from Harassment Act 1997.",
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
              ccms_category_law: "Family",
              ccms_matter: "domestic abuse (DA)",
            },
            {
              meaning: "Non-molestation order",
              ccms_code: "DA004",
              description: "to be represented on an application for a non-molestation order.",
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
              ccms_category_law: "Family",
              ccms_matter: "section 8 children (S8)",
            },
          ],
        },
        "SE095" =>
        {
          success: true,
          data: [
            {
              meaning: "Enforcement order 11J - appeal",
              ccms_code: "SE095A",
              description: "to be represented on an application for an enforcement order under section 11J Children Act 1989.  Appeals only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Enforcement order 11J",
              ccms_code: "SE095",
              description: "to be represented on an application for an enforcement order under section 11J Children Act 1989.  Enforcement only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
          ],
        },
        "SE003" =>
        {
          success: true,
          data: [
            {
              meaning: "Prohibited steps order - appeal",
              ccms_code: "SE003A",
              description: "to be represented on an application for a prohibited steps order.  Appeals only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Prohibited steps order",
              ccms_code: "SE003",
              description: "to be represented on an application for a prohibited steps order.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Prohibited steps order - enforcement",
              ccms_code: "SE003E",
              description: "to be represented on an application for a prohibited steps order.  Enforcement only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
          ],
        },
        "SE014" =>
        {
          success: true,
          data: [
            {
              meaning: "Child arrangements order (CAO) - residence",
              ccms_code: "SE014",
              description: "to be represented on an application for a child arrangements order –where the child(ren) will live",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Child arrangements order (CAO) - residence - enforcement",
              ccms_code: "SE014E",
              description: "to be represented on an application for a child arrangements order –where the child(ren) will live. Enforcement only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
            {
              meaning: "Child arrangements order (CAO) - residence - appeal",
              ccms_code: "SE014A",
              description: "to be represented on an application for a child arrangements order –where the child(ren) will live. Appeals only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
          ],
        },
        "SE004A" =>
        {
          success: true,
          data: [
            {
              meaning: "Specific issue order - appeal",
              ccms_code: "SE004A",
              description: "to be represented on an application for a specific issue order.  Appeals only.",
              sca_core: false,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "section 8 children (S8)",
            },
          ],
        },
        "Child assessment order SCA" =>
        {
          success: true,
          data: [
            {
              meaning: "Child assessment order",
              ccms_code: "PB003",
              description: "to be represented on an application for a child assessment order.",
              sca_core: true,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "special children act (SCA)",
            },
          ],
        },
        "secure accommodation order SCA" =>
        {
          success: true,
          data: [
            {
              meaning: "Secure accommodation order",
              ccms_code: "PB006",
              description: "to be represented on an application for a secure accommodation order.",
              sca_core: true,
              sca_related: false,
              non_means_tested_plf: false,
              ccms_category_law: "Family",
              ccms_category_law_code: "MAT",
              ccms_matter: "special children act (SCA)",
            },
          ],
        },
      },
    )
  end

  def countries_search_term_stubs
    Hash.new({ success: false, data: [] }.freeze).merge(
      {
        "France" =>
        {
          success: true,
          data: [
            {
              description: "France",
              code: "FRA",
              description_headline: "<mark>France</mark>",
            },
          ],
        },
      },
      {
        "fra" =>
        {
          success: true,
          data: [
            {
              description: "France",
              code: "FRA",
              description_headline: "<mark>France</mark>",
            },
          ],
        },
      },
      {
        "gree" =>
        {
          success: true,
          data: [
            {
              description: "Greenland",
              code: "GRL",
              description_headline: "<mark>Greenland</mark>",
            },
            {
              description: "Greece",
              code: "GRC",
              description_headline: "<mark>Greece</mark>",
            },
          ],
        },
      },
    )
  end
end

World(PuffingBillyHelper)
